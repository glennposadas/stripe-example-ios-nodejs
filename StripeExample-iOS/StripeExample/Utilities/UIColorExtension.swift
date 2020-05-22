//
//  UIColorExtension.swift
//  StripeExample
//
//  Created by Glenn Von Posadas on 5/17/20.
//  Copyright © 2020 GAM Dynamics. All rights reserved.
//

import UIKit

extension UIColor {
    /// Color mainly used for error internet notifier
    static let errorRed: UIColor = UIColor.colorWithRGBHex(0xff3f34)
    
    /// Hex to UIColor.
    class func colorWithRGBHex(_ hex: Int, alpha: Float = 1.0) -> UIColor {
        let r = Float((hex >> 16) & 0xFF)
        let g = Float((hex >> 8) & 0xFF)
        let b = Float((hex) & 0xFF)
        
        return UIColor(red: CGFloat(r / 255.0), green: CGFloat(g / 255.0), blue:CGFloat(b / 255.0), alpha: CGFloat(alpha))
    }
}
