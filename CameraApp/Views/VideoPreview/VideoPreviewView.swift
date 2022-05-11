//
//  VideoPreviewView.swift
//  BecomeAPresenter
//
//  Created by HC Studios on 8/21/20.
//  Copyright © 2020 HC Studios. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPreviewView: UIView {

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer.frame = UIScreen.main.bounds
        videoPreviewLayer.videoGravity = .resizeAspect
    }
    
}
