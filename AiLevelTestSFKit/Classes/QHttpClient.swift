//
//  QHttpClient.swift
//  REST
//
//  QHttpClient 2.0
//
//  Created by Junkyu Jeon on 11/18/15.
//  Copyright © 2015 Jeon Jun-kyu. All rights reserved.
//

import Foundation
import UIKit

let QHTTPCLIENT_FORCE_DEBUG = true

private let kBoundaryString = "---modoorepboundary236739405175924702888539212340aca3742955c---"

@objc protocol QHttpClientProgressDelegate {
    @objc optional func httpClient(_ httpClient: QHttpClient, updateProgress progress: Double)
}

let kHttpClientDebugError = "Error"
let kHttpClientDebugParams = "Params"
let kHttpClientDebugRequestUrl = "RequestUrl"
let kHttpClientDebugResponse = "Response"

private let supportsFormData = true

#if !QHttpClient_Block_Retrial_If_Failed
private let MaximumTrial = 5
#endif

private let errorExceptionUrls = [String]()

class QHttpClient: NSObject {
    typealias CallBack = (_ code: Code, _ errMessage: String?, _ response: Any?) -> Void
    
    public enum Code: String {
        case fail = "Failure"
        case success = "Success"
        case unreachableUrl = "Unreach"
        case timeOut = "TimeOut"
    }
    
    public enum Method: String {
        case Get = "GET"
        case Post = "POST"
        case Delete = "DELETE"
        case Put = "PUT"
    }
    
    public enum BodyType {
        case Json
        case FormData
    }
     
    public struct Attachment {
        public enum MediaType: Int {
            case Image = 0
            case PDF = 1
        }
        
        let data: Data
        let type: QHttpClient.Attachment.MediaType
        let fileName: String
        let key: String
    }

    public enum DebugStatus {
        case AllEnabled
        case PartlyEnabled
        case AllDisabled
    }

    public struct DebugMode {
        var error: Bool = true
        var params: Bool = false
        var requestUrl: Bool = false
        var response: Bool = false
    }
    
    public struct Parameter {
        let dict: [String:Any]
        
        func urlQueryString(percentEncode: Bool) -> String {
            var queryString = ""
            
            let keys = Array(dict.keys)
            
            if keys.count > 0 {
                for i in 0 ..< keys.count {
                    if queryString.count > 0 {
                        queryString += "&"
                    }
                    
                    let key = keys[i]
                    if let value = dict[key] {
                        if let valueArray = value as? [Any], let jsonData = try? JSONSerialization.data(withJSONObject: valueArray, options: []), let jsonString = String(data: jsonData, encoding: .utf8) {
//                            let jsonWriter = SBJsonWriter()
//                            queryString += "\(key)=" + jsonWriter.string(with: valueArray)
                             
                            queryString += "\(key)=" + jsonString
                        } else if let valueString = value as? String {
                            if percentEncode {
                                queryString += "\(key)=\(valueString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? valueString)"
                            } else {
                                queryString += "\(key)=\(valueString)"
                            }
                        } else {
                            queryString += "\(key)=\(value)"
                        }
                    }
                }
            }
            return queryString
        }
        
        var jsonData: Data? {
            get {
//                let jsonWriter = SBJsonWriter()
//                guard let string = jsonWriter.string(with: dict) else { return nil }
//                return string.data(using: .utf8)
                return try? JSONSerialization.data(withJSONObject: dict, options: [])
            }
        }
        
        var multipartFormData: Data {
            get {
                var data = Data()
                
                for (key, value) in dict {
                    if let array = value as? [Any] {
                        for i in 0 ..< array.count {
                            let subvalue = array[i]
                            
                            data.append("--\(kBoundaryString)\r\n".data(using: .utf8)!)
                            data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                            data.append("\(subvalue)\r\n".data(using: .utf8)!)
                        }
                        
                        continue
                    }
                    data.append("--\(kBoundaryString)\r\n".data(using: .utf8)!)
                    data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                    data.append("\(value)\r\n".data(using: .utf8)!)
                }
                
                return data
            }
        }
    }
    
    class func addCommonHeaderValue(_ value: String, for key: String) {
        QHttpClientSettings.shared.headerValues[key] = nil
        QHttpClientSettings.shared.headerValues[key] = value
    }
    
    class func removeCommonHeaderValue(for key: String) -> Bool {
        return QHttpClientSettings.shared.headerValues.removeValue(forKey: key) != nil
    }
    
    var method = QHttpClient.Method.Post
    var debugMode = QHttpClient.DebugMode(error: false, params: false, requestUrl: false, response: false)
    
    private var reqUrl: String?
    var url: String? {
        return reqUrl
    }
    
//    var bodyType = QHttpClient.BodyType.FormData
    
    var headerValues: [String:String]?
    var parameters: QHttpClient.Parameter?
    var attachments: [QHttpClient.Attachment]?
    var optionalData: [String:Any]?
    var completion: QHttpClient.CallBack?
    
    var progressDelegate: QHttpClientProgressDelegate?
    
    var blockTimeout = true
    
    var percentEncode = true
    
    #if !QHttpClient_Block_Retrial_If_Failed
    private var trialIndex = 0
    #endif
    
    private var doAfterCancel: (() -> Void)?
    var isCancelled: Bool {
        return doAfterCancel != nil
    }
    
    var state: URLSessionTask.State? {
        get {
            return task?.state
        }
    }
    
    var showErrorMessage = true
    
    var debugEnabled: [String] {
        get {
            var enabled: [String] = []
            if debugMode.error == true {enabled.append(kHttpClientDebugError)}
            if debugMode.params == true {enabled.append(kHttpClientDebugParams)}
            if debugMode.requestUrl == true {enabled.append(kHttpClientDebugRequestUrl)}
            if debugMode.response == true {enabled.append(kHttpClientDebugResponse)}
            return enabled
        }
    }
    
    var debugStatus: QHttpClient.DebugStatus {
        get {
            if debugMode.error == true && debugMode.params == true && debugMode.requestUrl == true && debugMode.response == true {
                return .AllEnabled
            } else if debugMode.error == false && debugMode.params == false && debugMode.requestUrl == false && debugMode.response == false {
                return .AllDisabled
            }
            
            return .PartlyEnabled
        }
    }
    
    fileprivate var task: URLSessionDataTask?
    fileprivate var timeInterval: Double?
    
    fileprivate let timeoutInterval = 60.0
    
    var identifier: Double? {
        return timeInterval
    }
    
    var includeCommonHeader = true
    
    var tag: Int = 0
    
    func sendRequest(to reqUrl: String, completion: QHttpClient.CallBack? = nil) {
        self.reqUrl = reqUrl
        
        var urlString = reqUrl
        
        self.toggleDebugs(QHTTPCLIENT_FORCE_DEBUG)
        
        if method == .Get || method == .Put{
            if let parameter = parameters {
                urlString += "?" + parameter.urlQueryString(percentEncode: percentEncode)
            }
        }
        
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        guard let url = URL(string: urlString) else {
            #if QHttpClient_FORCE_TO_DEBUG_JK
            print("QHttpClient: Unreachable URL")
            #endif
            completion?(.unreachableUrl, "알 수 없는 오류입니다.\n잠시 후 다시 시도해 주세요.", nil)
            return
        }
        
//        if attachments != nil {
//            self.bodyType = .FormData
//        }
        
        let request = NSMutableURLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeoutInterval)

        if includeCommonHeader {
            let headerValues = QHttpClientSettings.shared.headerValues
            let keys = Array(headerValues.keys)
            
            for key in keys {
                guard let value = headerValues[key] else {continue}
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let headerValues = headerValues {
            for (key, value) in headerValues {
                if request.value(forHTTPHeaderField: key) != nil { continue }
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        request.httpMethod = method.rawValue
        
        if method == .Post, let params = parameters {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let httpBody = params.urlQueryString(percentEncode: true).data(using: .utf8)
            request.httpBody = httpBody
        }
        
        #if QHttpClient_FORCE_TO_DEBUG_JK
        if debugMode.requestUrl {
            print("[QHttpClient] Request to : \(reqUrl)")
        }
        
        if debugMode.params {
            print("[QHttpClient] Request Header : \(String(describing: request.allHTTPHeaderFields))")
            print("[QHttpClient] Request Params : \(parameters?.urlQueryString(percentEncode: false) ?? "(No Parameters)")")
        }
        #endif
        
//        let queue = OperationQueue.main
//        let configuration = URLSessionConfiguration.default
//        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: queue)
//
        task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { [weak self] (data, response, error) -> Void in
            #if !QHttpClient_Block_Retrial_If_Failed
            if let self = self, response as? HTTPURLResponse == nil, self.trialIndex < MaximumTrial {
                self.trialIndex += 1
                
                self.cancel()
                self.retry(completion: completion)
                // Error
                return
            }
            #endif
            
            self?.task = nil
            
            guard let data = data else {
                DispatchQueue.main.async { [weak self] in
                    completion?(.fail, "알 수 없는 오류입니다.\n잠시 후 다시 시도해 주세요.", nil)
                    self?.doAfterCancel?()
                }
//                session.finishTasksAndInvalidate()
                return
            }
            
            let responseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String?
            
            if self?.timeInterval != nil {
                self?.timeInterval = Date().timeIntervalSince1970 - (self?.timeInterval ?? 0)
            }
            
            var responseData: Any?
            if responseString != nil {
                if let jsonData = try? responseString?.data(using: .utf8) {
                    responseData = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    // print(httpResponse.statusCode)
                    if httpResponse.statusCode != 200 {
                        #if QHttpClient_FORCE_TO_DEBUG_JK
                        if self?.debugMode.error ?? false {
                            print("[QHttpClient] Failed on error with code: \(httpResponse.statusCode) for \(urlString)")
                        }
                        #endif
                        DispatchQueue.main.async {
                            completion?(.fail, ((responseData as? [String:Any])?["message"] as? String) ?? "알 수 없는 오류입니다.\n잠시 후 다시 시도해 주세요.", responseData)
                        }

//                        session.finishTasksAndInvalidate()
                        return
//                    } else if errorExceptionUrls.firstIndex(of: urlString) == nil {

                    }
                }
            }
            
            #if QHttpClient_FORCE_TO_DEBUG_JK
            print("[QHttpClient] Response : \(responseString ?? "(No Response)")")
            #endif
            
            let statusInfo = (responseData as? [String:Any])?["status"] as? String ?? "Failure"
//            let code = Code(rawValue: statusInfo) ?? .fail
            let code = Code.success
            
            guard code == .success else {
                // print("[QHttpClient] Failed on error with code: \(code) (\(code.rawValue)) for \(urlString)")
                DispatchQueue.main.async {
                    completion?(code, ((responseData as? [String:Any])?["message"] as? String) ?? "알 수 없는 오류입니다.\n잠시 후 다시 시도해 주세요.", responseData)
                }
//                session.finishTasksAndInvalidate()
                return
            }
            
            if let timeInterval = self?.timeInterval {
                // print("[QHttpClient] Response Time : \(timeInterval) sec")
            }
            
            DispatchQueue.main.async {
                completion?(.success, nil, responseData ?? responseString)
            }
//            session.finishTasksAndInvalidate()
            
        })
        timeInterval = Date().timeIntervalSince1970
        task!.resume()
        
        if blockTimeout {return}
        
//        timerTimeout = Timer.scheduledTimer(withTimeInterval: timeoutInterval, repeats: false, block: { [weak self] (timer) in
//            QIndicatorViewManager.shared.hideIndicatorView()
//
//            self?.task?.cancel()
//
//            self?.timerTimeout?.invalidate()
//            self?.timerTimeout = nil
//
//            DispatchQueue.main.async {
//                completion?(.timeOut, "timeOut", nil)
//            }
//        })
    }
    
    func cancel(_ completion: (() -> Void)? = nil) {
        guard let task = task else {
            completion?()
            return
        }
        
        doAfterCancel = completion
        task.cancel()
    }
    
    func enableAllDebugs() {
        toggleDebugs(true)
    }
    
    func disableAllDebugs() {
        toggleDebugs(false)
    }
    
    func toggleDebugs(_ toggle: Bool) {
        debugMode.error = toggle
        debugMode.params = toggle
        debugMode.requestUrl = toggle
        debugMode.response = toggle
    }
    
    func retry(completion: QHttpClient.CallBack? = nil) {
        cancel()
        
        if completion != nil {
            self.completion = completion
        }
        self.sendRequest(to: url ?? "", completion: self.completion)
    }
    
    @objc func timeout(on viewController: UIViewController? = nil) {
        guard viewController != nil else {return}
        
        let alertController = UIAlertController(title: "서버에 연결할 수 없습니다.\n잠시 후 다시 시도해 주세요.", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "다시 시도", style: .cancel, handler: { (action) in
            self.retry()
        }))
        viewController!.present(alertController, animated: true)
    }
    
    private func getAttachmentData(attachment: Attachment) -> Data? {
        var fullData = Data()
        
        let lineOne = "--" + kBoundaryString + "\r\n"
        fullData.append(lineOne.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        
        let lineTwo = "Content-Disposition: form-data; name=\"\(attachment.key)\"; filename=\"" + attachment.fileName + "\"\r\n"
        fullData.append(lineTwo.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        
        let lineThree = "Content-Type: image/jpg\r\n\r\n"
        fullData.append(lineThree.data(using: String.Encoding.utf8,allowLossyConversion: false)!)
        
        fullData.append(attachment.data)
        
        let lineFive = "\r\n"
        fullData.append(lineFive.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        
        let lineSix = "--" + kBoundaryString + "--\r\n"
        fullData.append(lineSix.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        
        return fullData
    }
}

extension QHttpClient: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}

extension QHttpClient: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        progressDelegate?.httpClient?(self, updateProgress: progress)
    }
}

class QHttpClientSettings: NSObject {
    static let shared: QHttpClientSettings = QHttpClientSettings()
    var headerValues = [String:String]()
}
