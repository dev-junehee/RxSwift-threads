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

    struct Input {
        let filteredList: BehaviorRelay<[Shopping]>
        let addButtonTap: ControlEvent<Void>
        let searchText: ControlProperty<String?>
        let tableSelected: ControlEvent<Shopping>
    }
    
    struct Output {
        let filteredList: BehaviorRelay<[Shopping]>
        let addButtonTap: ControlEvent<Void>
        let searchText: Observable<String>
        let tableSelected: ControlEvent<Shopping>
    }
    
    func transform(input: Input) -> Output {
        
        // 검색
        let searchText = input.searchText
            .orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
    
        
        return Output(filteredList: input.filteredList,
                      addButtonTap: input.addButtonTap,
                      searchText: searchText,
                      tableSelected: input.tableSelected)
    }
    
}
