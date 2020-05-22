//
//  UIButtonExtension.swift
//  StripeExample
//
//  Created by Glenn Von Posadas on 5/17/20.
//  Copyright © 2020 GAM Dynamics. All rights reserved.
//

import UIKit

/// Category for adding helpfer methods for setting up buttons
extension UIButton {
    /// Setups the button with attributed text.
    func setup(
        _ title: String,
        normalFont: UIFont = UIFont.systemFont(ofSize: 14.0),
        normalTextColor: UIColor,
        highlightedFont: UIFont? = nil,
        highlightedTextColor: UIColor? = nil,
        backgroundColor: UIColor = .clear,
        horizontalAlignment: UIControl.ContentHorizontalAlignment = .center,
        isUnderlined: Bool = false,
        setGradientBG: Bool = false) {
        
        let normalAttrib = NSAttributedString(
            string: title,
            attributes: [
                .font : normalFont,
                .foregroundColor : normalTextColor,
                .underlineStyle : isUnderlined ? NSUnderlineStyle.single.rawValue : 0
            ]
        )
        
        self.setAttributedTitle(normalAttrib, for: .normal)
        self.contentHorizontalAlignment = horizontalAlignment
        self.contentVerticalAlignment = .center
        self.backgroundColor = backgroundColor
    }
}

