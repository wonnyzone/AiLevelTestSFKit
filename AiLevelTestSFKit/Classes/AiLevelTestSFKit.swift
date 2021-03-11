import Foundation

import UIKit
import SafariServices

internal struct RequestUrl {
    static let Base = "https://aileveltest.co.kr/"
    
    struct User {
        static let Validate = RequestUrl.Base + "index.php?module=y1member&act=apiClientCheck"
    }
    
    static let serviceUrl = "https://aileveltest.co.kr/plugin/api/init.php"
}

public class AiLevelTestSFKit: NSObject {
    public static var shared = AiLevelTestSFKit()
    
    private var _groupCode: String?
    private var _groupTitle: String?
    private var _email: String?
    private var _examId: String?
    
    public func activate(groupCode: String, email: String, examId: String, completion: ((_ isSucceed: Bool, _ errMessage: String?) -> Void)? = nil) {
        let httpClient = QHttpClient()
        httpClient.method = .Post
        
        var params = [String:Any]()
        params["group_code"] = groupCode
        params["examId"] = examId
        httpClient.parameters = QHttpClient.Parameter(dict: params)
        
        httpClient.sendRequest(to: RequestUrl.User.Validate) {[weak self] (code, errMessage, response) in
            guard code == .success, let responseData = response as? [String:Any], responseData["group_info"] as? [String:Any] != nil else {
                completion?(false, errMessage)
                return
            }
            
            self?._groupCode = groupCode
            self?._email = email
            self?._examId = examId
            
            completion?(true, nil)
        }
    }
    
    public func deactivate() {
        _groupCode = nil
        _email = nil
        _examId = nil
    }
    
    public func startTest(from viewController: UIViewController) {
        guard let mGroupCode = _groupCode, let mEmail = _email, let mExamId = _examId else {
            print("SDK가 초기화되지 않았습니다. activate 를 먼저 실행하십시오.")
            return
        }
        
        let urlString = RequestUrl.serviceUrl + "?code=\(mGroupCode)&email=\(mEmail)&exam_id=\(mExamId)"
        
        guard let url = URL(string: urlString) else {
            print("서비스URL을 생성할 수 없습니다.")
            return
        }
        
        let sfViewController = SFSafariViewController(url: url)
        viewController.present(sfViewController, animated: true, completion: nil)
    }
}
