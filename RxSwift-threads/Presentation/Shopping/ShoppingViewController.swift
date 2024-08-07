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

final class ShoppingViewController: BaseViewController {
    
    private let searchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "쇼핑 목록을 검색해 보세용 🔍"
        searchBar.searchTextField.font = .systemFont(ofSize: 12)
        return searchBar
    }()
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
        // view.delegate = self
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
    
    private lazy var filteredShoppingList = BehaviorRelay(value: originShoppingList)
    
    private let itemSelected = PublishSubject<Shopping>()
    
    private let viewModel = ShoppingViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func setViewController() {
        navigationItem.titleView = searchBar
        
        let fieldSubViews = [textField, addButton]
        fieldSubViews.forEach { fieldView.addSubview($0) }
        
        let views = [fieldView, tableView]
        views.forEach { view.addSubview($0) }
        
        fieldView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
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
        let input = ShoppingViewModel.Input(filteredList: filteredShoppingList,
                                            addButtonTap: addButton.rx.tap,
                                            searchText: searchBar.rx.text,
                                            tableSelected: tableView.rx.modelSelected(Shopping.self))
        let output = viewModel.transform(input: input)
        
        output.filteredList
            .bind(to: tableView.rx.items(cellIdentifier: ShoppingTableViewCell.id, cellType: ShoppingTableViewCell.self)) { (row, element, cell) in
                
                cell.updateCell(data: element)
                
                // 셀 체크버튼 탭
                cell.checkButton.rx.tap
                    .bind(with: self) { owner, _ in
                        owner.itemSelected.onNext(element)
                        owner.toggleCheckButton(row)
                    }
                    .disposed(by: cell.disposeBag)  // 셀에 있는 disposeBag!
                
                // 셀 즐찾버튼 탭
                cell.starButton.rx.tap
                    .bind(with: self) { owner, _ in
                        owner.toggleStarButton(row)
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        
        // 추가 버튼
        output.addButtonTap
            .bind(with: self) { owner, _ in
                guard let shoppingText = owner.textField.text else { return }
                owner.originShoppingList.insert(Shopping(name: shoppingText, done: false, favorite: false), at: 0)  // 데이터 추가
                owner.filteredShoppingList.accept(owner.originShoppingList)                                         // 필터링 데이터도 업데이트
                owner.tableView.reloadData()
                owner.textField.text = ""
            }
            .disposed(by: disposeBag)
        
        // 검색
        output.searchText
            .bind(with: self) { owner, value in
                let searched = value.isEmpty ? owner.originShoppingList : owner.originShoppingList.filter { $0.name.contains(value) }
                owner.filteredShoppingList.accept(searched)
            }
            .disposed(by: disposeBag)
        
        // 셀 클릭 + 화면 전환
        output.tableSelected
            .bind(with: self) { owner, data in
                let detail = ShoppingDetailViewController()
                detail.shoppingData = data
                owner.navigationController?.pushViewController(detail, animated: true)
            }
            .disposed(by: disposeBag)
        
        
        // 셀 삭제
        tableView.rx.itemDeleted
            .bind(with: self) { owner, indexPath in
                owner.originShoppingList.remove(at: indexPath.row)
                owner.filteredShoppingList.accept(owner.originShoppingList)
                self.tableView.reloadData()
            }
            .disposed(by: disposeBag)
    }
    
    private func toggleCheckButton(_ row: Int) {
        originShoppingList[row].done.toggle()
        filteredShoppingList.accept(originShoppingList)
    }
    
    private func toggleStarButton(_ row: Int) {
        originShoppingList[row].favorite.toggle()
        filteredShoppingList.accept(originShoppingList)
    }
    
}
