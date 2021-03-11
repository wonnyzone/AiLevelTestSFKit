//
//  LoginViewController.swift
//  AiLevelTestExample
//
//  Created by Jun-kyu Jeon on 2021/03/08.
//

import UIKit

import AiLevelTestSFKit

class LoginViewController: UIViewController {
    @IBOutlet var _labelGroupCode: UILabel!
    @IBOutlet var _labelId: UILabel!
    @IBOutlet var _labelExamId: UILabel!
    
    @IBOutlet var _textfieldGroupCode: UITextField!
    @IBOutlet var _textfieldId: UITextField!
    @IBOutlet var _textfieldExamId: UITextField!
    
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
        // examId : 시험 아이디
        // completion(isSucceed, errMessage) : 활성화 작업 완료 후 callback
        //      isSucceed : Bool    true : 활성화 성공
        //                          false : 활성화 실패
        //      errMessage : (String?) :  에러메세지
        
        AiLevelTestSFKit.shared.activate(groupCode: _textfieldGroupCode.text ?? "", email: _textfieldExamId.text ?? "", examId: _textfieldId.text ?? "") { [weak self] (isSucceed, errMessage) in
            guard isSucceed else {
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
