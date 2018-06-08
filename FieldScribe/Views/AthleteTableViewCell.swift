//
//  AthleteTableViewCell.swift
//  FieldScribe
//
//  Created by Cody Garvin on 11/27/17.
//  Copyright © 2017 OIT. All rights reserved.
//

import UIKit

class AthleteTableViewCell: UITableViewCell {
    
    ////////////////////////////////////////////////////////////////////////////
    // MARK: - Public Accessors & Mutators
    var isActive: Bool = true {
        didSet(newIsActive) {
            // Change colors for the view
            if newIsActive {
                mainLabel?.textColor = UIColor.fsMediumGreen()
                rightLabel?.textColor = UIColor.fsLightForeground()
            } else {
                mainLabel?.textColor = UIColor.fsLightGray()
                rightLabel?.textColor = UIColor.fsDarkGray()
            }
        }
    }
    
    var iconImage: UIImage? {
        get {
            return iconView?.image
        }
        set (newIconImage) {
            if newIconImage != nil {
                iconView?.image = newIconImage
                
                iconViewWidthConstraint?.isActive = false
                
                mainLabelLeadingConstraint?.constant = 14
                
            } else {
                iconView?.image = newIconImage
                

                iconViewWidthConstraint?.isActive = true
                
                mainLabelLeadingConstraint?.constant = 0
            }
        }
    }
    
    var mainLabel: UILabel? = nil
    var rightLabel: UILabel? = nil
    
    ////////////////////////////////////////////////////////////////////////////
    // MARK: - Private
    private
    var iconView: UIImageView? = nil
    private
    var iconViewWidthConstraint: NSLayoutConstraint? = nil
    private
    var mainLabelLeadingConstraint: NSLayoutConstraint? = nil
    
    ////////////////////////////////////////////////////////////////////////////
    // MARK: - Initializers
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        buildViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        iconImage = nil
    }
    
    private func buildViews() {
        
        backgroundColor = UIColor.fsDarkBackground()
        
        let backgroundContainerView = UIView()
        backgroundContainerView.translatesAutoresizingMaskIntoConstraints = false
        backgroundContainerView.backgroundColor = UIColor.fsDarkGray()
        backgroundContainerView.layer.cornerRadius = 8.0
        self.contentView.addSubview(backgroundContainerView)
        
        iconView = UIImageView(frame: CGRect.zero)
        iconView?.backgroundColor = UIColor.clear
        iconView?.translatesAutoresizingMaskIntoConstraints = false
        backgroundContainerView.addSubview(iconView!)
        
        mainLabel = UILabel(frame: CGRect.zero)
        mainLabel?.backgroundColor = UIColor.clear
        mainLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        mainLabel?.textColor = UIColor.fsMediumGreen()
        mainLabel?.translatesAutoresizingMaskIntoConstraints = false
        mainLabel?.numberOfLines = 0
        mainLabel?.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        backgroundContainerView.addSubview(mainLabel!)
        
        rightLabel = UILabel(frame: CGRect.zero)
        rightLabel?.backgroundColor = UIColor.clear
        rightLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
        rightLabel?.textColor = UIColor.fsLightForeground()
        rightLabel?.translatesAutoresizingMaskIntoConstraints = false
        rightLabel?.numberOfLines = 0
        rightLabel?.textAlignment = .right
        rightLabel?.setContentCompressionResistancePriority(.required, for: .horizontal)
        backgroundContainerView.addSubview(rightLabel!)
        
        // Now build the constraints cause we're aw3some
        backgroundContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7.0).isActive = true
        backgroundContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7.0).isActive = true
        backgroundContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 7.0).isActive = true
        backgroundContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -7.0).isActive = true
        
        iconView?.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor, constant: 14).isActive = true
        iconView?.bottomAnchor.constraint(lessThanOrEqualTo: backgroundContainerView.bottomAnchor, constant: -14).isActive = true
        iconView?.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 14).isActive = true
        iconViewWidthConstraint = iconView?.widthAnchor.constraint(equalToConstant: 0)
        iconViewWidthConstraint?.isActive = true
        
        
        mainLabel?.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor, constant: 14).isActive = true
        mainLabel?.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -14).isActive = true
        mainLabelLeadingConstraint = mainLabel?.leadingAnchor.constraint(equalTo: iconView!.trailingAnchor)
        mainLabelLeadingConstraint?.isActive = true
        mainLabel?.trailingAnchor.constraint(lessThanOrEqualTo: backgroundContainerView.trailingAnchor, constant: -14).isActive = true
        
        rightLabel?.topAnchor.constraint(equalTo: mainLabel!.topAnchor).isActive = true
        rightLabel?.bottomAnchor.constraint(lessThanOrEqualTo: backgroundContainerView.bottomAnchor, constant: -14).isActive = true
        rightLabel?.leadingAnchor.constraint(equalTo: mainLabel!.trailingAnchor, constant: 14).isActive = true
        rightLabel?.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -14).isActive = true
        
    }
}
