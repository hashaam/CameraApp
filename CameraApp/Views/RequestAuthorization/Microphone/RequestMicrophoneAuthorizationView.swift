//
//  RequestMicrophoneAuthorizationView.swift
//  BecomeAPresenter
//
//  Created by HC Studios on 8/10/20.
//  Copyright © 2020 HC Studios. All rights reserved.
//

import UIKit

protocol RequestMicrophoneAuthorizationViewDelegate: AnyObject {
    func requestMicrophoneAuthorizationTapped()
}

class RequestMicrophoneAuthorizationView: UIView {

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var microphoneImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var actionButton: UIButton!
    @IBOutlet private weak var actionButtonWidthConstraint: NSLayoutConstraint!
    
    weak var delegate: RequestMicrophoneAuthorizationViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
    }
    
    private func customInit() {
        let bundle = Bundle.main
        let nibName = String(describing: Self.self)
        bundle.loadNibNamed(nibName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        setupActionButtonShadow()
    }
                    
    @IBAction func actionButtonHandler(btn: UIButton) {
        delegate?.requestMicrophoneAuthorizationTapped()
    }
    
    func animateInViews() {
        let viewsToAnimate = [microphoneImageView, titleLabel, messageLabel, actionButton]
        for (i, viewToAnimate) in viewsToAnimate.enumerated() {
            guard let view = viewToAnimate else { continue }
            view.animateInView(delay: Double(i) * 0.15)
        }
    }
    
    func animateOutViews(completion: @escaping () -> Void) {
        let viewsToAnimate = [microphoneImageView, titleLabel, messageLabel, actionButton]
        for (i, viewToAnimate) in viewsToAnimate.enumerated() {
            guard let view = viewToAnimate else { continue }
            var completionHandler: (() -> Void)? = nil
            if viewToAnimate == viewsToAnimate.last {
                completionHandler = completion
            }
            view.animateOutView(delay: Double(i) * 0.15, completion: completionHandler)
        }
    }
    
    func configureForErrorState() {
        titleLabel.text = "Microphone Authorization Denied"
        actionButton.setTitle("Open Settings", for: .normal)
        actionButtonWidthConstraint.constant = 130
    }

}

private extension RequestMicrophoneAuthorizationView {
    func setupActionButtonShadow() {
        actionButton.addShadow()
    }
}
