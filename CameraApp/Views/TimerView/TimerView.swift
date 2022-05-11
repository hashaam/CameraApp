//
//  TimerView.swift
//  BecomeAPresenter
//
//  Created by HC Studios on 8/21/20.
//  Copyright © 2020 HC Studios. All rights reserved.
//

import UIKit

class TimerView: UIView {

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var timerLabel: UILabel!
    
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
    
    func updateTime(seconds: Int64) {
        let timeInterval = TimeInterval(integerLiteral: seconds)
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        let formattedString = formatter.string(from: timeInterval) ?? "00:00"
        timerLabel.text = formattedString
    }

}
