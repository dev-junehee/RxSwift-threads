//
//  BirthdayViewController.swift
//  RxSwift-threads
//
//  Created by junehee on 8/4/24.
//

import UIKit

// import RxCocoa
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
    
    private let viewModel = BirthdayViewModel()
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
        let input = BirthdayViewModel.Input(birthDay: datePicker.rx.date,
                                            signButtonTap: signButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.validText
            .bind(to: validationLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.year
            .map { "\($0)년" }
            .bind(to: yearLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.month
            .map { "\($0)월" }
            .bind(to: monthLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.day
            .map { "\($0)일" }
            .bind(to: dayLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.validation
            .bind(with: self) { owner, value in
                let labelColor: UIColor = value ? .blue : .red
                let buttonColor: UIColor = value ? .blue : .lightGray
                
                owner.validationLabel.textColor = labelColor
                owner.signButton.backgroundColor = buttonColor
                
                owner.signButton.isEnabled = value
            }
            .disposed(by: disposeBag)
        
        output.signButtonTap
            .bind(with: self) { owner, _ in
                owner.showAlert(title: "가입 완료!")
            }
            .disposed(by: disposeBag)
    }
    
}
