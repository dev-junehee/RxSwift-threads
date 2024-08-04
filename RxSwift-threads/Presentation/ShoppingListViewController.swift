//
//  ShoppingListViewController.swift
//  RxSwift-threads
//
//  Created by junehee on 8/4/24.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class ShoppingListViewController: BaseViewController {
    
    private let fieldView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.backgroundColor = .systemGroupedBackground
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let textField = {
        let field = UITextField()
        field.placeholder = "무엇을 구매하실 건가요?"
        field.font = .systemFont(ofSize: 12)
        return field
    }()
    
    private let addButton = {
        let button = UIButton()
        button.setTitle("추가", for: .normal)
        button.setTitleColor(Color.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        button.backgroundColor = .systemGray5
        button.layer.cornerRadius = 12
        return button
    }()
    
    private lazy var tableView = {
        let view = UITableView()
        view.delegate = self
        view.register(ShoppingTableViewCell.self, forCellReuseIdentifier: ShoppingTableViewCell.id)
        view.rowHeight = 54
        view.separatorStyle = .none
        return view
    }()
    
    private var originShoppingList = [
        Shopping(name: "그립톡 구매하기", done: true, favorite: true),
        Shopping(name: "사이다 구매", done: false , favorite: false),
        Shopping(name: "아이패드 케이스 최저가 알아보기", done: false, favorite: true),
        Shopping(name: "양말", done: false, favorite: false)
    ]
    
    private lazy var filteredShoppingList = BehaviorSubject(value: originShoppingList)
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func setViewController() {
        navigationItem.title = "쇼핑"
        
        let fieldSubViews = [textField, addButton]
        fieldSubViews.forEach { fieldView.addSubview($0) }
        
        view.addSubview(fieldView)
        view.addSubview(tableView)
        
        fieldView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(60)
        }
        
        addButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(fieldView.snp.trailing).inset(16)
            $0.width.equalTo(45)
            $0.height.equalTo(30)
        }
        
        textField.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(fieldView.snp.leading).offset(16)
            $0.trailing.equalTo(addButton.snp.leading).offset(16)
            $0.height.equalTo(40)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(fieldView.snp.bottom).offset(16)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func bind() {
        filteredShoppingList
            .bind(to: tableView.rx.items(cellIdentifier: ShoppingTableViewCell.id, cellType: ShoppingTableViewCell.self)) { (row, element, cell) in
                let data = self.originShoppingList[row]
                cell.updateCell(data: data)
            }
            .disposed(by: disposeBag)
        
        
        // 추가 버튼
        addButton
            .rx
            .tap
            .bind(with: self) { owner, _ in
                guard let shoppingText = owner.textField.text else { return }
                owner.originShoppingList.insert(Shopping(name: shoppingText, done: false, favorite: false), at: 0)  // 데이터 추가
                owner.filteredShoppingList.onNext(owner.originShoppingList)                                         // 필터링 데이터도 업데이트
                owner.tableView.reloadData()
            }
            .disposed(by: disposeBag)
        
        
        
        // 화면 전환
        tableView
            .rx
            .modelSelected(Shopping.self)
            .bind(with: self) { owner, _ in
                let detail = ShoppingDetailViewController()
                owner.navigationController?.pushViewController(detail, animated: true)
            }
            .disposed(by: disposeBag)
        
    }
    
}

extension ShoppingListViewController: UITableViewDelegate  {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let shopping = originShoppingList[indexPath.row]
        
        let delete = UIContextualAction(style: .destructive, title: "삭제" ) { _, _, _ in
            self.originShoppingList.remove(at: indexPath.row)
            self.filteredShoppingList.onNext(self.originShoppingList)
            self.tableView.reloadData()
        }
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
