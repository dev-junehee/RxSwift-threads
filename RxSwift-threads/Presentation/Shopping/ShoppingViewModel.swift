//
//  ShoppingViewModel.swift
//  RxSwift-threads
//
//  Created by junehee on 8/5/24.
//

import Foundation
import RxCocoa
import RxSwift

final class ShoppingViewModel {
    
    private let disposeBag = DisposeBag()
    
    // 쇼핑 리스트 (테이블뷰)
    var shoppingList = [
        Shopping(name: "그립톡 구매하기", done: true, favorite: true),
        Shopping(name: "사이다 구매", done: false , favorite: false),
        Shopping(name: "아이패드 케이스 최저가 알아보기", done: false, favorite: true),
        Shopping(name: "양말", done: false, favorite: false)
    ]
    
    // 최근 검색 (컬렉션뷰)
    var recentList = ["키보드", "뮤지컬", "양말", "모니터", "마우스패드", "안경"]
    
    struct Input {
        let addShoppingName: ControlProperty<String?>
        let addButtonTap: ControlEvent<Void>
        let searchText: ControlProperty<String?>
        let tableSelected: ControlEvent<Shopping>
        let tableDeleted: ControlEvent<IndexPath>
        let checkButtonRow: PublishSubject<Int>
        let starButtonRow: PublishSubject<Int>
        let recentSelected: ControlEvent<IndexPath>
    }
    
    struct Output {
        let filteredList: BehaviorSubject<[Shopping]>
        let recentList: BehaviorSubject<[String]>
        let addButtonTap: ControlEvent<Void>
        let tableSelected: ControlEvent<Shopping>
    }
    
    func transform(input: Input) -> Output {
        let filteredList = BehaviorSubject(value: shoppingList)
        let recentList = BehaviorSubject(value: recentList)
        
        var shoppingName: String = ""
        
        // 쇼핑목록 인풋 (textField)
        input.addShoppingName
            .orEmpty
            .subscribe(with: self) { owner, value in
                shoppingName = value
            }
            .disposed(by: disposeBag)
        
        // 추가 버튼 탭
        input.addButtonTap
            .bind(with: self) { owner, _ in
                owner.shoppingList.insert(Shopping(name: shoppingName, done: false, favorite: false), at: 0)
                filteredList.onNext(owner.shoppingList)
            }
            .disposed(by: disposeBag)
        
        // 검색
        input.searchText
            .orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(with: self) { owner, value in
                print("searchText", value)
                let searched = value.isEmpty ? owner.shoppingList : owner.shoppingList.filter { $0.name.contains(value) }
                filteredList.onNext(searched)
            }
            .disposed(by: disposeBag)
        
        // 셀 삭제
        input.tableDeleted
            .bind(with: self) { owner, indexPath in
                print("indexPath", indexPath)
                owner.shoppingList.remove(at: indexPath.row)
                filteredList.onNext(owner.shoppingList)
            }
            .disposed(by: disposeBag)
        
        // 버튼 핸들링
        input.checkButtonRow
            .bind(with: self) { owner, row in
                print("check", row)
                owner.shoppingList[row].done.toggle()
                filteredList.onNext(owner.shoppingList)
            }
            .disposed(by: disposeBag)
        
        input.starButtonRow
            .bind(with: self) { owner, row in
                print("star", row)
                owner.shoppingList[row].favorite.toggle()
                filteredList.onNext(owner.shoppingList)
            }
            .disposed(by: disposeBag)
        
        input.recentSelected
            .bind(with: self) { owner, indexPath in
                let selected = owner.recentList[indexPath.row]
                owner.shoppingList.insert(Shopping(name: selected, done: false, favorite: false), at: 0)
                filteredList.onNext(owner.shoppingList)
            }
            .disposed(by: disposeBag)
        
        
        return Output(filteredList: filteredList,
                      recentList: recentList,
                      addButtonTap: input.addButtonTap,
                      tableSelected: input.tableSelected)
    }
    
}
