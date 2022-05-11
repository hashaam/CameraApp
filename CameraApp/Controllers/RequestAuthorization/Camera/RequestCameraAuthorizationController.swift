//
//  RequestCameraAuthorizationController.swift
//  BecomeAPresenter
//
//  Created by HC Studios on 8/6/20.
//  Copyright © 2020 HC Studios. All rights reserved.
//

import Foundation
import AVFoundation

enum CameraAuthorizationStatus {
    case granted
    case notRequested
    case unauthorized
}

typealias RequestCameraAuthorizationCompletionHandler = (CameraAuthorizationStatus) -> Void

class RequestCameraAuthorizationController {
    
    static func requestCameraAuthorization(completionHandler: @escaping RequestCameraAuthorizationCompletionHandler) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                guard granted else {
                    completionHandler(.unauthorized)
                    return
                }
                completionHandler(.granted)
            }
        }
    }
    
    static func getCameraAuthorizationStatus() -> CameraAuthorizationStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized: return .granted
        case .notDetermined: return .notRequested
        default: return .unauthorized
        }
    }
    
}
