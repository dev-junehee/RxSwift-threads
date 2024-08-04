//
//  ShoppingTableViewCell.swift
//  RxSwift-threads
//
//  Created by junehee on 8/4/24.
//

import UIKit

final class ShoppingTableViewCell: UITableViewCell {
    
    static let id = "ShoppingCell"
    
    private let cellStack = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        return stack
    }()
    
    private let checkButton = {
        let button = UIButton()
        button.setImage(Image.check, for: .normal)
        button.tintColor = Color.black
        return button
    }()
    
    private let nameLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    private let starButton = {
        let button = UIButton()
        button.setImage(Image.star, for: .normal)
        button.tintColor = Color.black
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setTableViewCell()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 0))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setTableViewCell() {
        contentView.backgroundColor = .systemGroupedBackground
        
        let views = [checkButton, nameLabel, starButton]
        views.forEach { cellStack.addArrangedSubview($0) }
        contentView.addSubview(cellStack)
        contentView.layer.cornerRadius = 12
        
        cellStack.snp.makeConstraints {
            $0.edges.equalTo(contentView)
        }
        
        checkButton.snp.makeConstraints {
            $0.centerY.equalTo(cellStack)
            $0.leading.equalTo(cellStack.snp.leading)
            $0.size.equalTo(50)
        }
        
        starButton.snp.makeConstraints {
            $0.centerY.equalTo(cellStack)
            $0.trailing.equalTo(cellStack.snp.trailing)
            $0.size.equalTo(50)
        }
        
        nameLabel.snp.makeConstraints {
            $0.centerY.equalTo(cellStack)
            $0.leading.equalTo(checkButton.snp.trailing)
            $0.trailing.equalTo(starButton.snp.leading)
            $0.verticalEdges.equalTo(cellStack)
        }
    }
    
    func updateCell(data: Shopping) {
        let buttonImage = data.done ? Image.checkFill : Image.check
        checkButton.setImage(buttonImage, for: .normal)
        
        let starImage = data.favorite ? Image.starFill : Image.star
        starButton.setImage(starImage, for: .normal)
        
        nameLabel.text = data.name
    }

}
