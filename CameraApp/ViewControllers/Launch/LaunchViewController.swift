//
//  LaunchViewController.swift
//  BecomeAPresenter
//
//  Created by HC Studios on 8/6/20.
//  Copyright © 2020 HC Studios. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    
    private var requestCameraAuthorizationView: RequestCameraAuthorizationView?
    private var requestMicrophoneAuthorizationView: RequestMicrophoneAuthorizationView?
    private var requestPhotoLibraryAuthorizationView: RequestPhotoLibraryAuthorizationView?
    
    private var cameraAuthorizationStatus = RequestCameraAuthorizationController.getCameraAuthorizationStatus() {
        didSet {
            setupViewsForNextAuthorizationRequest()
        }
    }
    
    private var microphoneAuthorizationStatus = RequestMicrophoneAuthorizationController.getCameraAuthorizationStatus() {
        didSet {
            setupViewsForNextAuthorizationRequest()
        }
    }
    
    private var photoLibraryAuthorizationStatus = RequestPhotoLibraryAuthorizationController.getPhotoLibraryAuthorizationStatus() {
        didSet {
            setupViewsForNextAuthorizationRequest()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewsForNextAuthorizationRequest()
    }

}

private extension LaunchViewController {
    
    func setupViewsForNextAuthorizationRequest() {
        
        guard cameraAuthorizationStatus == .granted else {
            setupRequestCameraAuthorizationView()
            return
        }
        
        if let _ = requestCameraAuthorizationView {
            removeRequestCameraAuthorizationView()
            return
        }
        
        guard microphoneAuthorizationStatus == .granted else {
            setupRequestMicrophoneAuthorizationView()
            return
        }
        
        if let _ = requestMicrophoneAuthorizationView {
            removeRequestMicrophoneAuthorizationView()
            return
        }
        
        guard photoLibraryAuthorizationStatus == .granted else {
            setupRequestPhotoLibraryAuthorizationView()
            return
        }
        
        if let _ = requestPhotoLibraryAuthorizationView {
            removeRequestPhotoLibraryAuthorizationView()
            return
        }
        
        DispatchQueue.main.async {
            AppSetup.loadCaptureViewController()
        }
            
    }
    
    func setupRequestCameraAuthorizationView() {
        guard requestCameraAuthorizationView == nil else {
            if cameraAuthorizationStatus == .unauthorized {
                requestCameraAuthorizationView?.configureForErrorState()
            }
            return
        }
        let requestCameraAuthorizationView = RequestCameraAuthorizationView()
        requestCameraAuthorizationView.translatesAutoresizingMaskIntoConstraints = false
        requestCameraAuthorizationView.delegate = self
        view.addSubview(requestCameraAuthorizationView)
        NSLayoutConstraint.activate([
            requestCameraAuthorizationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            requestCameraAuthorizationView.topAnchor.constraint(equalTo: view.topAnchor),
            requestCameraAuthorizationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            requestCameraAuthorizationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        if cameraAuthorizationStatus == .unauthorized {
            requestCameraAuthorizationView.configureForErrorState()
        }
        requestCameraAuthorizationView.animateInViews()
        self.requestCameraAuthorizationView = requestCameraAuthorizationView
    }
    
    func removeRequestCameraAuthorizationView() {
        requestCameraAuthorizationView?.animateOutViews(completion: { [weak self] in
            guard let self = self else { return }
            self.requestCameraAuthorizationView = nil
            self.setupViewsForNextAuthorizationRequest()
        })
    }
    
    func setupRequestMicrophoneAuthorizationView() {
        guard requestMicrophoneAuthorizationView == nil else {
            if microphoneAuthorizationStatus == .unauthorized {
                requestMicrophoneAuthorizationView?.configureForErrorState()
            }
            return
        }
        let requestMicrophoneAuthorizationView = RequestMicrophoneAuthorizationView()
        requestMicrophoneAuthorizationView.translatesAutoresizingMaskIntoConstraints = false
        requestMicrophoneAuthorizationView.delegate = self
        view.addSubview(requestMicrophoneAuthorizationView)
        NSLayoutConstraint.activate([
            requestMicrophoneAuthorizationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            requestMicrophoneAuthorizationView.topAnchor.constraint(equalTo: view.topAnchor),
            requestMicrophoneAuthorizationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            requestMicrophoneAuthorizationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        if microphoneAuthorizationStatus == .unauthorized {
            requestMicrophoneAuthorizationView.configureForErrorState()
        }
        requestMicrophoneAuthorizationView.animateInViews()
        self.requestMicrophoneAuthorizationView = requestMicrophoneAuthorizationView
    }
    
    func removeRequestMicrophoneAuthorizationView() {
        requestMicrophoneAuthorizationView?.animateOutViews(completion: { [weak self] in
            guard let self = self else { return }
            self.requestMicrophoneAuthorizationView = nil
            self.setupViewsForNextAuthorizationRequest()
        })
    }
    
    func setupRequestPhotoLibraryAuthorizationView() {
        guard requestPhotoLibraryAuthorizationView == nil else {
            if photoLibraryAuthorizationStatus == .unauthorized {
                requestPhotoLibraryAuthorizationView?.configureForErrorState()
            }
            return
        }
        let requestPhotoLibraryAuthorizationView = RequestPhotoLibraryAuthorizationView()
        requestPhotoLibraryAuthorizationView.translatesAutoresizingMaskIntoConstraints = false
        requestPhotoLibraryAuthorizationView.delegate = self
        view.addSubview(requestPhotoLibraryAuthorizationView)
        NSLayoutConstraint.activate([
            requestPhotoLibraryAuthorizationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            requestPhotoLibraryAuthorizationView.topAnchor.constraint(equalTo: view.topAnchor),
            requestPhotoLibraryAuthorizationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            requestPhotoLibraryAuthorizationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        if photoLibraryAuthorizationStatus == .unauthorized {
            requestPhotoLibraryAuthorizationView.configureForErrorState()
        }
        requestPhotoLibraryAuthorizationView.animateInViews()
        self.requestPhotoLibraryAuthorizationView = requestPhotoLibraryAuthorizationView
    }
    
    func removeRequestPhotoLibraryAuthorizationView() {
        requestPhotoLibraryAuthorizationView?.animateOutViews(completion: { [weak self] in
            guard let self = self else { return }
            self.requestPhotoLibraryAuthorizationView = nil
            self.setupViewsForNextAuthorizationRequest()
        })
    }
        
    func openSettings() {
        let settingsURLString = UIApplication.openSettingsURLString
        if let settingsURL = URL(string: settingsURLString) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }
}

extension LaunchViewController: RequestCameraAuthorizationViewDelegate {
    func requestCameraAuthorizationTapped() {
        if cameraAuthorizationStatus == .notRequested {
            RequestCameraAuthorizationController.requestCameraAuthorization { [weak self] status in
                guard let self = self else { return }
                self.cameraAuthorizationStatus = status
            }
            return
        }
        
        if cameraAuthorizationStatus == .unauthorized {
            openSettings()
            return
        }
    }
}


extension LaunchViewController: RequestMicrophoneAuthorizationViewDelegate {
    func requestMicrophoneAuthorizationTapped() {
        if microphoneAuthorizationStatus == .notRequested {
            RequestMicrophoneAuthorizationController.requestMicrophoneAuthorization { [weak self] status in
                guard let self = self else { return }
                self.microphoneAuthorizationStatus = status
            }
            return
        }
        
        if microphoneAuthorizationStatus == .unauthorized {
            openSettings()
            return
        }
    }
}

extension LaunchViewController: RequestPhotoLibraryAuthorizationViewDelegate {
    func requestPhotoLibraryAuthorizationTapped() {
        if photoLibraryAuthorizationStatus == .notRequested {
            RequestPhotoLibraryAuthorizationController.requestPhotoLibraryAuthorization { [weak self] status in
                guard let self = self else { return }
                self.photoLibraryAuthorizationStatus = status
            }
            return
        }
        
        if photoLibraryAuthorizationStatus == .unauthorized {
            openSettings()
            return
        }
    }
}
