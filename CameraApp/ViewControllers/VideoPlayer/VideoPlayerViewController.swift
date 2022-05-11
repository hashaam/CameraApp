//
//  VideoPlayerViewController.swift
//  BecomeAPresenter
//
//  Created by HC Studios on 5/12/22.
//  Copyright © 2022 HC Studios. All rights reserved.
//

import UIKit
import AVKit

protocol VideoPlayerViewControllerDelegate: AnyObject {
    func videoPlayerViewControllerDismissed(videoPlayerViewController: VideoPlayerViewController)
}

class VideoPlayerViewController: AVPlayerViewController {
    
    weak var videoPlayerViewControllerDelegate: VideoPlayerViewControllerDelegate?
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoPlayerViewControllerDelegate?.videoPlayerViewControllerDismissed(videoPlayerViewController: self)
    }

}
