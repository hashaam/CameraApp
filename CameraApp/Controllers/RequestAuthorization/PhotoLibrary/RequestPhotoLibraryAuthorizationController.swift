//
//  RequestPhotoLibraryAuthorizationController.swift
//  BecomeAPresenter
//
//  Created by HC Studios on 8/18/20.
//  Copyright © 2020 HC Studios. All rights reserved.
//

import Foundation
import Photos

enum PhotoLibraryAuthorizationStatus {
    case granted
    case notRequested
    case unauthorized
}

typealias RequestPhotoLibraryAuthorizationCompletionHandler = (PhotoLibraryAuthorizationStatus) -> Void

class RequestPhotoLibraryAuthorizationController {
    
    static func requestPhotoLibraryAuthorization(completionHandler: @escaping RequestPhotoLibraryAuthorizationCompletionHandler) {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                guard status == .authorized else {
                    completionHandler(.unauthorized)
                    return
                }
                completionHandler(.granted)
            }
        }
    }
    
    static func getPhotoLibraryAuthorizationStatus() -> PhotoLibraryAuthorizationStatus {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized: return .granted
        case .notDetermined: return .notRequested
        default: return .unauthorized
        }
    }
    
}
