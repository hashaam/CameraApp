//
//  UIView+AddShadow.swift
//  BecomeAPresenter
//
//  Created by HC Studios on 8/18/20.
//  Copyright © 2020 HC Studios. All rights reserved.
//

import UIKit

extension UIView {
    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 5, height: 10)
        layer.masksToBounds = true
        layer.cornerRadius = 4
    }
}
