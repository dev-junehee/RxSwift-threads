//
//  ShoppingCollectionViewCell.swift
//  RxSwift-threads
//
//  Created by junehee on 8/7/24.
//

import UIKit
import SnapKit

final class ShoppingCollectionViewCell: UICollectionViewCell {
    
    static let id = "ShoppingCollectionViewCell"
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        label.backgroundColor = .systemGroupedBackground
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 13)
        label.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
