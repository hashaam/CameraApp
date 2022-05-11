//
//  AppSetup.swift
//  BecomeAPresenter
//
//  Created by HC Studios on 8/18/20.
//  Copyright © 2020 HC Studios. All rights reserved.
//

import UIKit

class AppSetup {
    
    static func loadCaptureViewController() {
        let nibName = String(describing: CaptureViewController.self)
        let bundle = Bundle.main
        let captureViewController = CaptureViewController(nibName: nibName, bundle: bundle)
        let window = Self.keyWindow
        window?.rootViewController = captureViewController
        window?.makeKeyAndVisible()
    }
    
    static var keyWindow: UIWindow? {
        let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return firstScene?.windows.first(where: { $0.isKeyWindow })
    }
    
    static var interfaceOrientation: UIInterfaceOrientation? {
        let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return firstScene?.interfaceOrientation
    }
    
}
