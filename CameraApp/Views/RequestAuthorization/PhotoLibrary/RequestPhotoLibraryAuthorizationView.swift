//
//  RequestPhotoLibraryAuthorizationView.swift
//  BecomeAPresenter
//
//  Created by HC Studios on 8/18/20.
//  Copyright © 2020 HC Studios. All rights reserved.
//

import UIKit

protocol RequestPhotoLibraryAuthorizationViewDelegate: AnyObject {
    func requestPhotoLibraryAuthorizationTapped()
}

class RequestPhotoLibraryAuthorizationView: UIView {

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var actionButton: UIButton!
    @IBOutlet private weak var actionButtonWidthConstraint: NSLayoutConstraint!
    
    weak var delegate: RequestPhotoLibraryAuthorizationViewDelegate?
    
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
        
        addActionButtonShadow()
    }
    
    @IBAction func actionButtonHandler(btn: UIButton) {
        delegate?.requestPhotoLibraryAuthorizationTapped()
    }
    
    func animateInViews() {
        let viewsToAnimate = [photoImageView, titleLabel, messageLabel, actionButton]
        for (i, viewToAnimate) in viewsToAnimate.enumerated() {
            guard let view = viewToAnimate else { continue }
            view.animateInView(delay: Double(i) * 0.15)
        }
    }
    
    func animateOutViews(completion: @escaping () -> Void) {
        let viewsToAnimate = [photoImageView, titleLabel, messageLabel, actionButton]
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
        titleLabel.text = "Photo Library Authorization Denied"
        actionButton.setTitle("Open Settings", for: .normal)
        actionButtonWidthConstraint.constant = 130
    }

}

private extension RequestPhotoLibraryAuthorizationView {
    func addActionButtonShadow() {
        actionButton.addShadow()
    }
}
