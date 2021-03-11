//
//  TestListViewController.swift
//  AiLevelTestExample
//
//  Created by Jun-kyu Jeon on 2021/03/08.
//

import UIKit

import AiLevelTestKit

class TestListViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "테스트 리스트"
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .red
        button.clipsToBounds = true
        button.layer.cornerRadius = 8
        button.setTitle("테스트 시작하기", for: .normal)
        button.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        self.view.addSubview(button)
        
        button.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
        button.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.6).isActive = true
        button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    @objc private func pressedButton(_ button: UIButton) {
        AiLevelTestKit.shared.startTestWith(id: "57000", from: self)
//        AiLevelTestKit.shared.startTest(from: self, withId: "examId")
    }
}
