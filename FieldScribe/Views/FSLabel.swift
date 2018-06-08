//
//  FSLabel.swift
//  FieldScribe
//
//  Created by Cody Garvin on 5/1/18.
//  Copyright © 2018 OIT. All rights reserved.
//

import UIKit

class FSLabel: UILabel {

    var topInset: CGFloat = 8.0
    var bottomInset: CGFloat = 8.0
    var leftInset: CGFloat = 7.0
    var rightInset: CGFloat = 7.0
    var selected: Bool = false {
        didSet {
            
            guard let attributedText = self.attributedText else { return }
            let tempString = NSMutableAttributedString(attributedString: attributedText)
            var color = UIColor.fsLightForeground()
            if selected {
                color = UIColor.fsMediumGreen()
            }
            tempString.addAttribute(.foregroundColor, value: color, range: NSMakeRange(0, tempString.length))
            self.attributedText = tempString
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        self.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.numberOfLines = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawText(in rect: CGRect) {
        
        let insets = UIEdgeInsets.init(top: topInset, left: leftInset,
                                       bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
        
    }
    
    override var intrinsicContentSize: CGSize {
        
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += topInset + bottomInset
        intrinsicSuperViewContentSize.width += leftInset + rightInset
       
        return intrinsicSuperViewContentSize
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        
        // Adjust the frame
        var tempFrame = self.frame
        tempFrame.origin.x = tempFrame.origin.x + leftInset
        tempFrame.origin.y = tempFrame.origin.y + topInset
        tempFrame.size.width = tempFrame.size.width + leftInset + rightInset
        tempFrame.size.height = tempFrame.size.height + topInset + bottomInset
        self.frame = tempFrame
    }
}
