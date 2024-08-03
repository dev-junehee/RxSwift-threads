//
//  BirthdayViewController.swift
//  RxSwift-threads
//
//  Created by junehee on 8/4/24.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

/**
 1) 화면 진입 시 - 데이트픽커(오늘 날짜) / 레이블 노출
 2) 데이터픽커 선택 시 - 나이 계산 + 만 17세 이상 체크 (미통과시 레이블 색상 빨간색, 버튼 비활성화, 버튼 회색)
 3) 유효성 검사 통과 시 - 버튼 색상 파란색, 버튼 활성화
 4) 버튼 클릭 시 - Alert
 */

final class BirthdayViewController: BaseViewController {
    
    private let validationLabel = UILabel()
    
    private let dateStack = UIStackView()
    private let yearLabel = UILabel()
    private let monthLabel = UILabel()
    private let dayLabel = UILabel()
  
    
    private let datePicker = UIDatePicker()
    private let signButton = PointButton(title: "가입하기")
    
    private let validText = Observable.just("만 17세 이상만 가입 가능합니다.")
    
    private let year = BehaviorSubject(value: 0000)
    private let month = BehaviorSubject(value: 00)
    private let day = BehaviorSubject(value: 00)
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
  
    override func setViewController() {
        let views = [validationLabel, dateStack, datePicker, signButton]
        views.forEach { view.addSubview($0) }
        
        let labels = [yearLabel, monthLabel, dayLabel]
        labels.forEach { 
            dateStack.addArrangedSubview($0)
            $0.snp.makeConstraints { make in
                make.width.equalTo(60)
            }
        }
        
        let safeArea = view.safeAreaLayoutGuide
        
        validationLabel.snp.makeConstraints {
            $0.top.equalTo(safeArea).offset(100)
            $0.horizontalEdges.equalTo(safeArea)
            $0.height.equalTo(20)
        }
        validationLabel.textAlignment = .center
        
        dateStack.snp.makeConstraints {
            $0.top.equalTo(validationLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(safeArea).inset(40)
            $0.height.equalTo(20)
        }
        dateStack.axis = .horizontal
        dateStack.distribution = .equalSpacing
        dateStack.alignment = .center
        
        datePicker.snp.makeConstraints {
            $0.top.equalTo(dateStack.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(safeArea)
            $0.height.equalTo(200)
        }
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ko-KR")
        datePicker.maximumDate = Date()
        
        signButton.snp.makeConstraints {
            $0.top.equalTo(datePicker.snp.bottom).offset(50)
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            $0.height.equalTo(50)
        }
    }
    
    private func bind() {
        validText
            .bind(to: validationLabel.rx.text)
            .disposed(by: disposeBag)
        
        datePicker
            .rx
            .date
            .bind(with: self) { owner, date in
                // print(date)     // 2024-08-03 16:09:02 +0000
                
                let component = Calendar.current.dateComponents([.year, .month, .day], from: date)
                // print(component)    // year: 2024 month: 8 day: 4 isLeapMonth: false
                
                if let year = component.year, let month = component.month, let day = component.day {
                    owner.year.onNext(year)
                    owner.month.onNext(month)
                    owner.day.onNext(day)
                }
                
            }
            .disposed(by: disposeBag)
        
        year
            .map { "\($0)년" }
            .bind(to: yearLabel.rx.text)
            .disposed(by: disposeBag)
        
        month
            .map { "\($0)월" }
            .bind(to: monthLabel.rx.text)
            .disposed(by: disposeBag)
        
        day
            .map { "\($0)일" }
            .bind(to: dayLabel.rx.text)
            .disposed(by: disposeBag)
        
        let validation = datePicker
            .rx
            .date
            .map { date in
                let thisYear = Calendar.current.dateComponents([.year], from: Date())      // 올해 연도
                let targetYear = Calendar.current.dateComponents([.year], from: date)      // 타겟 연도
                
                if let this = thisYear.year, let target = targetYear.year {
                    return this - target >= 17 ? true : false   //
                }
                return false
            }
        
        validation
            .bind(with: self) { owner, value in
                let labelColor: UIColor = value ? .blue : .red
                let buttonColor: UIColor = value ? .blue : .lightGray
                
                owner.validationLabel.textColor = labelColor
                owner.signButton.backgroundColor = buttonColor
                
                owner.signButton.isEnabled = value
            }
            .disposed(by: disposeBag)
        
        signButton
            .rx
            .tap
            .bind(with: self) { owner, _ in
                owner.showAlert(title: "가입 완료!")
            }
            .disposed(by: disposeBag)
    }
    
}
