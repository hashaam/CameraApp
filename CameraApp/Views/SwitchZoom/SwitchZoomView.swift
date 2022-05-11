//
//  SwitchZoomView.swift
//  BecomeAPresenter
//
//  Created by HC Studios on 9/11/20.
//  Copyright © 2020 HC Studios. All rights reserved.
//

import UIKit

enum ZoomState {
    case ultrawide
    case wide
    case telephoto
}

protocol SwitchZoomViewDelegate: AnyObject {
    func switchZoomTapped(state: ZoomState)
}

class SwitchZoomView: UIView {

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var ultrawideButton: UIButton!
    @IBOutlet private weak var wideButton: UIButton!
    @IBOutlet private weak var telephotoButton: UIButton!
    
    private var zoomState = ZoomState.wide
    
    private var selectedButton: UIButton?
    
    weak var delegate: SwitchZoomViewDelegate?
    
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
        
        wideButton.setTitleColor(.selected, for: .normal)
        selectedButton = wideButton
    }
    
    @IBAction func ultrawideButtonHandler(btn: UIButton) {
        selectedButton?.setTitleColor(.textOnBackgroundAlpha, for: .normal)
        zoomState = .ultrawide
        ultrawideButton.setTitleColor(.selected, for: .normal)
        selectedButton = ultrawideButton
        delegate?.switchZoomTapped(state: zoomState)
    }
    
    @IBAction func wideButtonHandler(btn: UIButton) {
        selectedButton?.setTitleColor(.textOnBackgroundAlpha, for: .normal)
        zoomState = .wide
        wideButton.setTitleColor(.selected, for: .normal)
        selectedButton = wideButton
        delegate?.switchZoomTapped(state: zoomState)
    }
    
    @IBAction func telephotoButtonHandler(btn: UIButton) {
        selectedButton?.setTitleColor(.textOnBackgroundAlpha, for: .normal)
        zoomState = .telephoto
        telephotoButton.setTitleColor(.selected, for: .normal)
        selectedButton = telephotoButton
        delegate?.switchZoomTapped(state: zoomState)
    }
    
    func hideUltrawideButton() {
        ultrawideButton.isHidden = true
    }
    
    func hideTelephotoButton() {
        telephotoButton.isHidden = true
    }
    
    func configureForPortraitOrientation() {
        stackView.axis = .horizontal
    }
    
    func configureForLandscapeOrientation() {
        stackView.axis = .vertical
    }
    
}
