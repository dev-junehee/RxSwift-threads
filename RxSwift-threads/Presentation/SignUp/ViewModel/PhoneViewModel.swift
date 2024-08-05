//
//  PhoneViewModel.swift
//  RxSwift-threads
//
//  Created by junehee on 8/5/24.
//

import Foundation
import RxCocoa
import RxSwift

final class PhoneViewModel {
    
    struct Input {
        let phoneText: ControlProperty<String?>
        let nextButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let defaultText: Observable<String>
        let validText: Observable<String>
        let validation: Observable<Bool>
        let nextButtonTap: ControlEvent<Void>
    }
    
    func transform(input: Input) -> Output {
        let validation = input.phoneText
            .orEmpty
            .map { $0.count >= 10 && Int($0) != nil }
        
        return Output(defaultText: Observable.just("010"),
                      validText: Observable.just("10자 이상 입력해 주세요."),
                      validation: validation,
                      nextButtonTap: input.nextButtonTap)
    }
    
}
