//
//  ViewController.swift
//  RxSwift-threads
//
//  Created by junehee on 8/1/24.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

/**
 `Observable` - 이벤트를 전달하는 역할
 `Observer`- 이벤트를 받아서 코드의 실행 결과를 보여주는 역할
 
 1) 비밀번호는 8자리 이상 입력
 2) 비밀번호 조건이 맞지 않을 경우 - nextButton 밝은 회색 / 클릭X + descriptionLabel 노출
 3) 비밀번호 조건이 맞는 경우 - nextButton 핑크색 / 클릭O + descriptionLabel 숨김
 */

final class PasswordViewController: BaseViewController {
    
    private let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해 주세요.")
    private let descriptionLabel = UILabel()
    private let nextButton = PointButton(title: "다음")
    
    private let viewModel = PasswordViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func setViewController() {
        let views = [passwordTextField, nextButton, descriptionLabel]
        views.forEach { view.addSubview($0) }
        
        let safeArea = view.safeAreaLayoutGuide
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(safeArea).offset(200)
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            $0.height.equalTo(50)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(4)
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            $0.height.equalTo(20)
        }
        
        nextButton.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(30)
            $0.horizontalEdges.equalTo(safeArea).inset(16)
            $0.height.equalTo(50)
        }
    }

    func bind() {
        let input = PasswordViewModel.Input(passwordText: passwordTextField.rx.text,
                                            nextButtonTap: nextButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        // descriptionLabel에 바로 할당
        output.validText
            .bind(to: descriptionLabel.rx.text)
            .disposed(by: disposeBag)
        
        // validation이 true일 때 nextButton 활성화 + descriptionLabel 숨김 처리
        output.validation
            .bind(to: nextButton.rx.isEnabled, descriptionLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        // validation 값에 따라 nextButton 색상 변경
        output.validation
            .bind(with: self) { owner, value in
                let color: UIColor = value ? .systemPink : .lightGray
                owner.nextButton.backgroundColor = color
            }
            .disposed(by: disposeBag)
        
        output.nextButtonTap
            .bind(with: self) { owner, _ in
                owner.showAlert(title: "다음 버튼 클릭!")
            }
            .disposed(by: disposeBag)
    }
    
}

