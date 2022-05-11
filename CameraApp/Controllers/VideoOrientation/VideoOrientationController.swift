//
//  VideoOrientationController.swift
//  BecomeAPresenter
//
//  Created by HC Studios on 9/21/20.
//  Copyright © 2020 HC Studios. All rights reserved.
//

import UIKit
import AVFoundation

class VideoOrientationController {
    
    static func getVideoOrientation(interfaceOrientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation? {
        switch interfaceOrientation {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        default:
            return nil
        }
    }
    
}
