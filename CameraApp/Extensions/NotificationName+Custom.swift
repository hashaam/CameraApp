//
//  NotificationName+Custom.swift
//  BecomeAPresenter
//
//  Created by HC Studios on 9/21/20.
//  Copyright © 2020 HC Studios. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    static var ApplicationDidBecomeActive = Notification.Name(rawValue: "ApplicationDidBecomeActive")
    
    static var ApplicationWillResignActive = Notification.Name(rawValue: "ApplicationWillResignActive")
    
}
