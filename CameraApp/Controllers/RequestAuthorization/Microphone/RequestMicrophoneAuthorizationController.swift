//
//  RequestMicrophoneAuthorizationController.swift
//  BecomeAPresenter
//
//  Created by HC Studios on 8/11/20.
//  Copyright © 2020 HC Studios. All rights reserved.
//

import Foundation
import AVFoundation

enum MicrophoneAuthorizationStatus {
    case granted
    case notRequested
    case unauthorized
}

typealias RequestMicrophoneAuthorizationCompletionHandler = (MicrophoneAuthorizationStatus) -> Void

class RequestMicrophoneAuthorizationController {
    
    static func requestMicrophoneAuthorization(completionHandler: @escaping RequestMicrophoneAuthorizationCompletionHandler) {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            DispatchQueue.main.async {
                guard granted else {
                    completionHandler(.unauthorized)
                    return
                }
                completionHandler(.granted)
            }
        }
    }
    
    static func getCameraAuthorizationStatus() -> MicrophoneAuthorizationStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        switch status {
        case .authorized: return .granted
        case .notDetermined: return .notRequested
        default: return .unauthorized
        }
    }
    
}
