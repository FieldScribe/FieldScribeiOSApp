//
//  UIColor+FieldScribe.swift
//  FieldScribe
//
//  Created by Cody Garvin on 4/24/18.
//  Copyright © 2018 OIT. All rights reserved.
//

import UIKit

extension  UIColor {

    // 12 12 12
    static func fsDarkBackground() -> UIColor {
        return UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
    }
    
    // 242 242 242
    static func fsLightForeground() -> UIColor {
        return UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
    }
    
    // 42 42 42
    static func fsDarkGray() -> UIColor {
        return UIColor(red: 0.164, green: 0.164, blue: 0.164, alpha: 1.0)
    }
    
    // 153 153 153
    static func fsMediumGray() -> UIColor {
        return UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
    }
    
    // 216 216 216
    static func fsLightGray() -> UIColor {
        return UIColor(red: 0.847, green: 0.847, blue: 0.847, alpha: 1.0)
    }
    
    // 144 203 64
    static func fsMediumGreen() -> UIColor {
        return UIColor(red: 0.564, green: 0.79, blue: 0.25, alpha: 1.0)
    }
}
