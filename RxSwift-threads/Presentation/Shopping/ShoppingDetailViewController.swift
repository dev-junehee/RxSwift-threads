//
//  ShoppingDetailViewController.swift
//  RxSwift-threads
//
//  Created by junehee on 8/4/24.
//

import Foundation

final class ShoppingDetailViewController: BaseViewController {
    
    var shoppingData: Shopping?
    
    override func setViewController() {
        guard let shoppingData else { return }
        // navigationItem.title = "쇼핑 상세"
        navigationItem.title = shoppingData.name
    }
    
    
}
