# AiLevelTestSFKit

[![CI Status](https://img.shields.io/travis/jk-gna/AiLevelTestSFKit.svg?style=flat)](https://travis-ci.org/jk-gna/AiLevelTestSFKit)
[![Version](https://img.shields.io/cocoapods/v/AiLevelTestSFKit.svg?style=flat)](https://cocoapods.org/pods/AiLevelTestSFKit)
[![Platform](https://img.shields.io/cocoapods/p/AiLevelTestSFKit.svg?style=flat)](https://cocoapods.org/pods/AiLevelTestSFKit)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

AiLevelTestSFKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'AiLevelTestSFKit'
```

## Usage

그룹코드 및 이메일, 시허아이디로 프레임웍 활성화 및 인증
```swift
AiLevelTestSFKit.shared.activate(groupCode: "allinone07834", email: "evan", examId: "lv_ko_en_a") { [weak self] (isSucceed, errMessage) in
        guard isSucceed else {
            // 홯성화 실패시 실패 사유를 alert으로 보여준다
            
            let alertController = UIAlertController(title: errMessage, message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
            self?.present(alertController, animated: true, completion: nil)
            
            return
        }

        // 활성화 및 인증 성공
    }
```

프레임웍 비활성화
```swift
AiLevelTestSFKit.shared.deactivate()
```

테스트 시작하기
```swift
AiLevelTestSFKit.shared.startTest(from: self)
```

## Author

JK, junq.jeon@gmail.com

## License

AiLevelTestSFKit , 2021 All-in-one edu-tech, inc. All rights reserved.
