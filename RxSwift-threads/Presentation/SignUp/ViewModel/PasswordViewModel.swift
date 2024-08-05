//
//  PasswordViewModel.swift
//  RxSwift-threads
//
//  Created by junehee on 8/5/24.
//

import Foundation
import RxCocoa
import RxSwift

final class PasswordViewModel {
    
    struct Input {
        let passwordText: ControlProperty<String?>
        let nextButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let validText: Observable<String>
        let validation: Observable<Bool>
        let nextButtonTap: ControlEvent<Void>
    }
    
    func transform(input: Input) -> Output {
        let validation = input.passwordText
            .orEmpty
            .map {  $0.count >= 8  }
        
        let validText = Observable.just("8자리 이상 입력해 주세요.")
        
        return Output(validText: validText,
                      validation: validation,
                      nextButtonTap: input.nextButtonTap)
    }
    
}
