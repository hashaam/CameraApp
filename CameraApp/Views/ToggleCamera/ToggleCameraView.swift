//
//  ToggleCameraView.swift
//  BecomeAPresenter
//
//  Created by HC Studios on 9/21/20.
//  Copyright © 2020 HC Studios. All rights reserved.
//

import UIKit

protocol ToggleCameraViewDelegate: AnyObject {
    func toggleCameraTapped()
}

class ToggleCameraView: UIView {

    @IBOutlet private weak var contentView: UIView!
    
    weak var delegate: ToggleCameraViewDelegate?
    
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
    }
    
    @IBAction func toggleButtonHandler(btn: UIButton) {
        delegate?.toggleCameraTapped()
    }

}
