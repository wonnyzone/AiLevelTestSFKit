//
//  LoginViewController.swift
//  AiLevelTestExample
//
//  Created by Jun-kyu Jeon on 2021/03/08.
//

import UIKit

import AiLevelTestKit

class LoginViewController: UIViewController {
    @IBOutlet var _labelGroupCode: UILabel!
    @IBOutlet var _labelId: UILabel!
    
    @IBOutlet var _textfieldGroupCode: UITextField!
    @IBOutlet var _textfieldId: UITextField!
    
    @IBOutlet var _buttonStart: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "로그인"
        
        _buttonStart.backgroundColor = .red
        _buttonStart.clipsToBounds = true
        _buttonStart.layer.cornerRadius = 8
        _buttonStart.setTitle("로그인", for: .normal)
        _buttonStart.setTitleColor(.white, for: .normal)
        _buttonStart.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        
        _ = validateButtonEnabled()
    }
    
    private func validateButtonEnabled() -> Bool {
        _buttonStart.isEnabled = (_textfieldId.text ?? "").count > 0 && (_textfieldGroupCode.text ?? "").count > 0
        return _buttonStart.isEnabled
    }
    
    @IBAction func login(_ button: UIButton) {
        guard validateButtonEnabled() else { return }
        
        // ** 레벨테스트 활성화. AiLevelTestKit.shared.activate
        // groupCode : 할당받은 그룹코드
        // email : 이메일
        // themeColour : 테마 색상
        // completion(code, errMessage) : 활성화 작업 완료 후 callback
        //      code : (ALTResponseCode)    Succeed : 활성화 성공
        //                                  Failed : 활성화 실패
        //                                  Unknown : 활성화 실패 (알 수 없음)
        //      errMessage : (String?) :  에러메세지
        
        AiLevelTestKit.shared.activate(groupCode: _textfieldGroupCode.text ?? "", email: _textfieldId.text ?? "", themeColour: #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)) { [weak self] (code, errMessage) in
            guard code == .Succeed else {
                // 초기화 실패시 실패 사유를 alert으로 보여준다
                
                let alertController = UIAlertController(title: errMessage, message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                self?.present(alertController, animated: true, completion: nil)
                
                return
            }
            // 초기화 성공시 다음 화면으로 진입한다.
            
            let viewController = TestListViewController()
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        _ = validateButtonEnabled()
    }
    
    @IBAction func textFieldDidEndOnExit(_ textField: UITextField) {
        if textField == _textfieldGroupCode {
            _ = _textfieldId.becomeFirstResponder()
        } else {
            _ = _textfieldId.resignFirstResponder()
        }
    }
}
