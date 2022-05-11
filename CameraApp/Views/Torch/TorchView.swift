//
//  TorchView.swift
//  BecomeAPresenter
//
//  Created by HC Studios on 11/3/20.
//  Copyright © 2020 HC Studios. All rights reserved.
//

import UIKit

enum TorchMode {
    case off
    case on
}

protocol TorchViewDelegate: AnyObject {
    func torchTapped(torchMode: TorchMode, completionHandler: (Bool) -> Void)
}

class TorchView: UIView {

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var torchButton: UIButton!
    
    private var torchMode = TorchMode.off
    
    weak var delegate: TorchViewDelegate?
    
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
    
    @IBAction func torchButtonHandler(btn: UIButton) {
        delegate?.torchTapped(torchMode: torchMode, completionHandler: { [weak self] success in
            guard let self = self else { return }
            guard success else { return }
            switch self.torchMode {
            case .off:
                self.torchButton.tintColor = .selected
                self.torchMode = .on
            case .on:
                self.torchButton.tintColor = .textOnBackgroundAlpha
                self.torchMode = .off
            }
        })
    }

}
