//
//  TimerController.swift
//  BecomeAPresenter
//
//  Created by HC Studios on 8/21/20.
//  Copyright © 2020 HC Studios. All rights reserved.
//

import Foundation

typealias TimerUpdateHandler = (Int64) -> Void

class TimerController {
    
    private var timer: Timer?
    private var seconds: Int64 = 0
    
    func setupTimer(timerUpdateHandler: @escaping TimerUpdateHandler) {
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.seconds += 1
            timerUpdateHandler(self.seconds)
        }
        self.timer = timer
    }
    
    func resetTimer() {
        timer?.invalidate()
        timer = nil
        seconds = 0
    }
    
}
