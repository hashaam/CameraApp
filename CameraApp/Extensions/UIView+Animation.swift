//
//  UIView+Animation.swift
//  BecomeAPresenter
//
//  Created by HC Studios on 8/18/20.
//  Copyright © 2020 HC Studios. All rights reserved.
//

import UIKit

extension UIView {
    func animateInView(delay: TimeInterval) {
        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: -20)
        let animation = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
            self.alpha = 1
            self.transform = .identity
        }
        animation.startAnimation(afterDelay: delay)
    }
    
    func animateOutView(delay: TimeInterval, completion: (() -> Void)? = nil) {
        let animation = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
            self.alpha = 0
            self.transform = CGAffineTransform(translationX: 0, y: -20)
        }
        animation.startAnimation(afterDelay: delay)
        animation.addCompletion { _ in
            completion?()
        }
    }
}
