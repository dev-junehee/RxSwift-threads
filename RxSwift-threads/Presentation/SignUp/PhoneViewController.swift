//
//  PhoneViewController.swift
//  RxSwift-threads
//
//  Created by junehee on 8/3/24.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

/**
 1) 첫 화면 진입 시  `010`을 텍스트필드에 바로 노출
 2) 전화번호 텍스트필드에는 숫자만 가능
 3) 전화번호는 10자리 이상
 4) 전화번호 조건이 맞는 경우 - nextButton 핑크색 / 클릭O + descriptionLabel 숨김
 5) 전화번호 조건이 맞지않는 경우 - nextButton 밝은회색 / 클릭X + descriptionLabel 노출
 */

final class PhoneViewController: BaseViewController {
    
    private let phoneTextField = SignTextField(placeholderText: "전화번호를 입력해 주세요.")
    private let descriptionLabel = UILabel()
    private let nextButton = PointButton(title: "다음")
    
    // private let defaultText = Observable.just("010")
    // private let validText = Observable.just("10자 이상 입력해 주세요.")
    
    private let viewModel = PhoneViewModel()
    private let disposeBag = DisposeBag()
    
    private let minPhoneLength = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func setViewController() {
        let views = [phoneTextField, descriptionLabel, nextButton]
        views.forEach { view.addSubview($0) }
        
        let safeArea = view.safeAreaLayoutGuide
        phoneTextField.snp.makeConstraints {
            $0.top.equalTo(safeArea).offset(200)
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            $0.height.equalTo(50)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(phoneTextField.snp.bottom).offset(4)
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            $0.height.equalTo(20)
        }
        
        nextButton.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(30)
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            $0.height.equalTo(50)
        }
        
        phoneTextField.keyboardType = .numberPad
    }
    
    private func bind() {
        let input = PhoneViewModel.Input(phoneText: phoneTextField.rx.text,
                                         nextButtonTap: nextButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        // 첫 화면 진입 시 phoneTextField에 '010' 띄우기
        output.defaultText
            .bind(to: phoneTextField.rx.text)
            .disposed(by: disposeBag)
        
        // descriptionLabel 유효성 검사 텍스트
        // 첫 화면 진입 시 '10자리 이상 입력해 주세요' 노출
        output.validText
            .bind(to: descriptionLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 유효성 검사 true - 10자리 이상일 때 + 숫자일 때
        output.validation
            .bind(to: nextButton.rx.isEnabled, descriptionLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.validation
            .bind(with: self) { owner, value in
                let color: UIColor = value ? .systemMint : .lightGray
                owner.nextButton.backgroundColor = color
            }
            .disposed(by: disposeBag)
        
        output.nextButtonTap
            .bind(with: self) { owner, value in
                owner.showAlert(title: "다음 버튼 클릭!")
            }
            .disposed(by: disposeBag)
    }
    
}
