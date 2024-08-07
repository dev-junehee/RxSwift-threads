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
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    private lazy var tableView = {
        let view = UITableView()
        // view.delegate = self
        view.register(ShoppingTableViewCell.self, forCellReuseIdentifier: ShoppingTableViewCell.id)
        view.rowHeight = 54
        view.separatorStyle = .none
        return view
    }()
    
    private func layout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 40)
        layout.scrollDirection = .horizontal
        return layout
    }
    
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
        
        let views = [fieldView, collectionView, tableView]
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
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(fieldView.snp.bottom).offset(16)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(40)
        }
        collectionView.register(ShoppingCollectionViewCell.self, forCellWithReuseIdentifier: ShoppingCollectionViewCell.id)
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(16)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func bind() {
        let checkButtonRow = PublishSubject<Int>()
        let starButtonRow = PublishSubject<Int>()
        
        let input = ShoppingViewModel.Input(addShoppingName: textField.rx.text,
                                            addButtonTap: addButton.rx.tap,
                                            searchText: searchBar.rx.text,
                                            tableSelected: tableView.rx.modelSelected(Shopping.self),
                                            tableDeleted: tableView.rx.itemDeleted,
                                            checkButtonRow: checkButtonRow,
                                            starButtonRow: starButtonRow,
                                            recentSelected: collectionView.rx.itemSelected)
        let output = viewModel.transform(input: input)
        
        output.filteredList
            .bind(to: tableView.rx.items(cellIdentifier: ShoppingTableViewCell.id, cellType: ShoppingTableViewCell.self)) { (row, element, cell) in
                
                cell.updateCell(data: element)
                
                // 셀 체크버튼 탭
                cell.checkButton.rx.tap
                    .bind(with: self) { owner, _ in
                        checkButtonRow.onNext(row)
                    }
                    .disposed(by: cell.disposeBag)  // 셀에 있는 disposeBag!
                
                // 셀 즐찾버튼 탭
                cell.starButton.rx.tap
                    .bind(with: self) { owner, _ in
                        starButtonRow.onNext(row)
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output.recentList
            .bind(to: collectionView.rx.items(cellIdentifier: ShoppingCollectionViewCell.id, cellType: ShoppingCollectionViewCell.self)) { (row, element, cell) in
                cell.label.text = "\(element)"
            }
            .disposed(by: disposeBag)
        
        // 추가 버튼
        output.addButtonTap
            .bind(with: self) { owner, _ in
                owner.textField.text = ""
            }
            .disposed(by: disposeBag)
        
        // 테이블뷰 셀 클릭 + 화면 전환
        output.tableSelected
            .bind(with: self) { owner, data in
                let detail = ShoppingDetailViewController()
                detail.shoppingData = data
                owner.navigationController?.pushViewController(detail, animated: true)
            }
            .disposed(by: disposeBag)
        
        
        
    }

    
}
