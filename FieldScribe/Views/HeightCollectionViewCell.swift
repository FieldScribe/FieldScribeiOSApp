//
//  HeightCollectionViewCell.swift
//  FieldScribe
//
//  Created by Cody Garvin on 5/19/18.
//  Copyright © 2018 OIT. All rights reserved.
//

import UIKit

class HeightCollectionViewCell: UICollectionViewCell {
    
    var mainLabel: UILabel
    
    override init(frame: CGRect) {
        
        mainLabel = UILabel(frame: .zero)
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        mainLabel.font = UIFont.systemFont(ofSize: 16)
        mainLabel.textColor = UIColor.fsLightForeground()
        mainLabel.textAlignment = .center
        
        super.init(frame: frame)
        
        contentView.addSubview(mainLabel)
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 3
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.fsMediumGray().cgColor
        
        buildConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet(newIsActive) {
            if newIsActive {
                mainLabel.font = UIFont.boldSystemFont(ofSize: 16)
                contentView.layer.borderColor = UIColor.white.cgColor
            } else {
                mainLabel.font = UIFont.systemFont(ofSize: 16)
                contentView.layer.borderColor = UIColor.fsMediumGray().cgColor
            }
        }
    }
    
    private func buildConstraints() {
        mainLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14).isActive = true
        mainLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14).isActive = true
        mainLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        mainLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
}
