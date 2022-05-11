//
//  PointOfInterestView.swift
//  BecomeAPresenter
//
//  Created by HC Studios on 11/3/20.
//  Copyright © 2020 HC Studios. All rights reserved.
//

import UIKit

class PointOfInterestView: UIView {

    @IBOutlet private weak var contentView: UIView!
    
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
        
        contentView.layer.borderColor = UIColor.yellow.cgColor
        contentView.layer.borderWidth = 1
    }

}
