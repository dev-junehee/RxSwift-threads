//
//  BirthdayViewModel.swift
//  RxSwift-threads
//
//  Created by junehee on 8/5/24.
//

import Foundation
import RxCocoa
import RxSwift

final class BirthdayViewModel {
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let birthDay: ControlProperty<Date>
        let signButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let year: BehaviorRelay<Int>
        let month: BehaviorRelay<Int>
        let day: BehaviorRelay<Int>
        let validText: Observable<String>
        let validation: Observable<Bool>
        let signButtonTap: ControlEvent<Void>
    }
    
    func transform(input: Input) -> Output {
        let year = BehaviorRelay(value: 0000)
        let month = BehaviorRelay(value: 00)
        let day = BehaviorRelay(value: 00)
        
        input.birthDay
            .bind(with: self) { owner, date in
                let component = Calendar.current.dateComponents([.year, .month, .day], from: date)
                
                if let yearComp = component.year, let monthComp = component.month, let dayComp = component.day {
                    year.accept(yearComp)
                    month.accept(monthComp)
                    day.accept(dayComp)
                }
            }
            .disposed(by: disposeBag)
        
        let validation = input.birthDay
            .map { date in
                let thisYear = Calendar.current.dateComponents([.year], from: Date())  // 올해
                let targetYear = Calendar.current.dateComponents([.year], from: date)  // 타겟
                
                if let this = thisYear.year, let target = targetYear.year {
                    return this - target >= 17 ? true : false   //
                }
                return false
            }
       
        return Output(year: year,
                      month: month,
                      day: day,
                      validText: Observable.just("만 17세 이상만 가입 가능합니다."),
                      validation: validation,
                      signButtonTap: input.signButtonTap)
    }
    
}
