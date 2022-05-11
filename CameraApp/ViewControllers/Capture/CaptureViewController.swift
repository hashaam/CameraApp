//
//  CaptureViewController.swift
//  BecomeAPresenter
//
//  Created by HC Studios on 8/18/20.
//  Copyright © 2020 HC Studios. All rights reserved.
//

import UIKit
import AVKit

class CaptureViewController: UIViewController {
    
    @IBOutlet private weak var videoPreviewView: VideoPreviewView!
    @IBOutlet private weak var visualEffectView: UIVisualEffectView!
    @IBOutlet private weak var overlayView: UIView!
    @IBOutlet private weak var timerView: TimerView!
    @IBOutlet private weak var torchView: TorchView!
    @IBOutlet private weak var alertView: AlertView!
    @IBOutlet private weak var switchZoomView: SwitchZoomView!
    @IBOutlet private weak var toggleCameraView: ToggleCameraView!
    @IBOutlet private weak var recordView: RecordView!
    @IBOutlet private weak var pointOfInterestView: PointOfInterestView!
    
    private var captureSessionController = CaptureSessionController()
    
    private var portraitConstraints = [NSLayoutConstraint]()
    private var landscapeConstraints = [NSLayoutConstraint]()
    
    private lazy var timerController = TimerController()
    
    private var switchZoomViewWidthConstraint: NSLayoutConstraint?
    private var switchZoomViewHeightConstraint: NSLayoutConstraint?
    
    private var shouldHideSwitchZoomView = false
    
    private var hideAlertViewWorkItem: DispatchWorkItem?
    
    private var pointOfInterestHalfCompletedWorkItem: DispatchWorkItem?
    private var pointOfInterestCompletedWorkItem: DispatchWorkItem?
    
    private var movieOutputFileURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecordView()
        setupTorchView()
        setupVisualEffectView()
        setupToggleCameraView()
        setupCaptureSessionController()
        registerForApplicationStateNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initializeConstraints()
        showInitialViews()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        hideViewsBeforeOrientationChange()
        coordinator.animate(alongsideTransition: { [weak self] context in
            guard let self = self else { return }
            self.setupVideoOrientation()
        }) { [weak self] context in
            guard let self = self else { return }
            self.setupOrientationConstraints(size: size)
            self.showViewsAfterOrientationChange()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .ApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: .ApplicationWillResignActive, object: nil)
    }
    
    @IBAction func overlayViewTapHandler(tapGestureRecognizer: UITapGestureRecognizer) {
        guard let tapView = tapGestureRecognizer.view else { return }
        let tapLocation = tapGestureRecognizer.location(in: tapView)
        let newLocation = tapView.convert(tapLocation, to: view)
        showPointOfInterestViewAtPoint(point: newLocation)
        let devicePoint = videoPreviewView.videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: tapLocation)
        captureSessionController.setFocus(
            focusMode: .autoFocus,
            exposureMode: .autoExpose,
            atPoint: devicePoint,
            shouldMonitorSubjectAreaChange: true
        )
    }
    
    override var shouldAutorotate: Bool {
        return !captureSessionController.isRecording
    }

}

private extension CaptureViewController {
    func initializeConstraints() {
        portraitConstraints = [
            recordView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            recordView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            switchZoomView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            switchZoomView.heightAnchor.constraint(equalToConstant: 60),
            switchZoomView.bottomAnchor.constraint(equalTo: recordView.topAnchor, constant: -30),
            toggleCameraView.centerYAnchor.constraint(equalTo: recordView.centerYAnchor),
            toggleCameraView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30)
        ]
        
        landscapeConstraints = [
            recordView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            recordView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            switchZoomView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            switchZoomView.widthAnchor.constraint(equalToConstant: 60),
            switchZoomView.trailingAnchor.constraint(equalTo: recordView.leadingAnchor, constant: -30),
            toggleCameraView.centerXAnchor.constraint(equalTo: recordView.centerXAnchor),
            toggleCameraView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30)
        ]
        
        let switchZoomViewWidthConstraint = switchZoomView.widthAnchor.constraint(equalToConstant: 160)
        portraitConstraints.append(switchZoomViewWidthConstraint)
        self.switchZoomViewWidthConstraint = switchZoomViewWidthConstraint
        
        let switchZoomViewHeightConstraint = switchZoomView.heightAnchor.constraint(equalToConstant: 160)
        landscapeConstraints.append(switchZoomViewHeightConstraint)
        self.switchZoomViewHeightConstraint = switchZoomViewHeightConstraint
        
        let screenSize = UIScreen.main.bounds.size
        setupOrientationConstraints(size: screenSize)
    }
    
    func setupOrientationConstraints(size: CGSize) {
        if size.width > size.height {
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
            switchZoomView.configureForLandscapeOrientation()
        } else {
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
            switchZoomView.configureForPortraitOrientation()
        }
    }
    
    func setupTimer() {
        timerController.setupTimer(timerUpdateHandler: { [weak self] seconds in
            guard let self = self else { return }
            self.timerView.updateTime(seconds: seconds)
            print(seconds)
        })
    }
    
    func hideViewsBeforeOrientationChange() {
        recordView.alpha = 0
        toggleCameraView.alpha = 0
        switchZoomView.alpha = 0
        hidePointOfInterestView()
    }
    
    func showViewsAfterOrientationChange() {
        let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.recordView.alpha = 1
            self.toggleCameraView.alpha = 1
            self.switchZoomView.alpha = 1
        }
        animation.startAnimation()
    }
    
    func setupSwitchZoomView() {
        switchZoomView.delegate = self
        
        if let cameraTypes = captureSessionController.getCameraTypes() {
            if cameraTypes.filter({ $0 == CameraType.ultrawide }).isEmpty {
                switchZoomView.hideUltrawideButton()
                reduceSwitchZoomViewSize()
            }
            
            if cameraTypes.filter({ $0 == CameraType.telephoto }).isEmpty {
                switchZoomView.hideTelephotoButton()
                reduceSwitchZoomViewSize()
            }
            
            if cameraTypes == [.wide] {
                switchZoomView.isHidden = true
                shouldHideSwitchZoomView = true
            }
        }
    }
    
    func setupCaptureSessionController() {
        captureSessionController.delegate = self
        captureSessionController.initializeCaptureSession(completionHandler: { [weak self] in
            guard let self = self else { return }
            self.videoPreviewView.videoPreviewLayer.session = self.captureSessionController.getCaptureSession()
            self.setupVideoOrientation()
            self.setupToggleCameraView()
            self.setupSwitchZoomView()
        })
    }
    
    func setupToggleCameraView() {
        toggleCameraView.delegate = self
    }
    
    func setupVisualEffectView() {
        visualEffectView.effect = nil
    }
    
    func registerForApplicationStateNotifications() {
        NotificationCenter.default.addObserver(
            forName: .ApplicationDidBecomeActive,
            object: nil,
            queue: .main) { [weak self] notification in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.visualEffectView.effect = nil
            } completion: { _ in
                
            }
            self.captureSessionController.startRunning()
        }
        
        NotificationCenter.default.addObserver(
            forName: .ApplicationWillResignActive,
            object: nil,
            queue: .main) { [weak self] notification in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.visualEffectView.effect = UIBlurEffect(style: .dark)
            } completion: { _ in
                
            }
            self.captureSessionController.stopRunning()
        }
    }
    
    func setupVideoOrientation() {
        guard let interfaceOrientation = AppSetup.interfaceOrientation else { return }
        guard let videoOrientation = VideoOrientationController.getVideoOrientation(interfaceOrientation: interfaceOrientation) else { return }
        videoPreviewView.videoPreviewLayer.connection?.videoOrientation = videoOrientation
    }
    
    func reduceSwitchZoomViewSize() {
        let delta: CGFloat = 50
        switchZoomViewWidthConstraint?.constant -= delta
        switchZoomViewHeightConstraint?.constant -= delta
    }
    
    func showInitialViews() {
        recordView.isHidden = false
        if !shouldHideSwitchZoomView {
            switchZoomView.isHidden = false
        }
        toggleCameraView.isHidden = false
    }
    
    func showAndHideAlertView(text: String) {
        showAlertView(text: text)
        let hideAlertViewWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.hideAlertView()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: hideAlertViewWorkItem)
        self.hideAlertViewWorkItem = hideAlertViewWorkItem
    }
    
    func showAlertView(text: String) {
        hideAlertViewWorkItem?.cancel()
        hideAlertViewWorkItem = nil
        
        alertView.alpha = 0
        alertView.setAlertText(text: text)
        alertView.transform = CGAffineTransform(translationX: 0, y: 30)
        let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.alertView.transform = .identity
            self.alertView.alpha = 1
        }
        animation.startAnimation()
    }
    
    func hideAlertView() {
        let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.alertView.transform = CGAffineTransform(translationX: 0, y: 30)
            self.alertView.alpha = 0
        }
        animation.startAnimation()
    }
    
    func setupTorchView() {
        torchView.delegate = self
    }
    
    func showPointOfInterestViewAtPoint(point: CGPoint) {
        pointOfInterestHalfCompletedWorkItem = nil
        pointOfInterestCompletedWorkItem = nil
        
        pointOfInterestView.center = point
        pointOfInterestView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.pointOfInterestView.transform = .identity
            self.pointOfInterestView.alpha = 1
        }
        animation.startAnimation()
        
        let pointOfInterestHalfCompletedWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
                self.pointOfInterestView.alpha = 0.5
            }
            animation.startAnimation()
        }
        
        let pointOfInterestCompletedWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
                self.pointOfInterestView.alpha = 0
            }
            animation.startAnimation()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: pointOfInterestHalfCompletedWorkItem)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: pointOfInterestCompletedWorkItem)
        
        self.pointOfInterestHalfCompletedWorkItem = pointOfInterestHalfCompletedWorkItem
        self.pointOfInterestCompletedWorkItem = pointOfInterestCompletedWorkItem
    }
    
    func hidePointOfInterestView() {
        pointOfInterestHalfCompletedWorkItem?.cancel()
        pointOfInterestCompletedWorkItem?.cancel()
        pointOfInterestHalfCompletedWorkItem = nil
        pointOfInterestCompletedWorkItem = nil
        pointOfInterestView.alpha = 0
    }
    
    func showTimerView() {
        timerView.isHidden = false
    }
    
    func hideTimerView() {
        timerView.isHidden = true
    }
    
    func resetTimer() {
        timerController.resetTimer()
    }
    
    func setupRecordView() {
        recordView.delegate = self
    }
    
}

extension CaptureViewController: SwitchZoomViewDelegate {
    func switchZoomTapped(state: ZoomState) {
        hidePointOfInterestView()
        captureSessionController.setZoomState(zoomState: state)
    }
}

extension CaptureViewController: ToggleCameraViewDelegate {
    func toggleCameraTapped() {
        hidePointOfInterestView()
        captureSessionController.toggleCamera(completionHandler: { [weak self] cameraPosition in
            guard let self = self else { return }
            switch cameraPosition {
            case .front:
                self.switchZoomView.isHidden = true
                self.torchView.isHidden = true
            case .back:
                if !self.shouldHideSwitchZoomView {
                    self.switchZoomView.isHidden = false
                }
                self.torchView.isHidden = false
            }
        })
    }
}

extension CaptureViewController: TorchViewDelegate {
    func torchTapped(torchMode: TorchMode, completionHandler: (Bool) -> Void) {
        switch torchMode {
        case .off:
            let result = captureSessionController.turnOnTorch()
            if !result {
                showAndHideAlertView(text: "Could not turn on torch")
            }
            completionHandler(result)
        case .on:
            let result = captureSessionController.turnOffTorch()
            if !result {
                showAndHideAlertView(text: "Could not turn off torch")
            }
            completionHandler(result)
        }
    }
}

extension CaptureViewController: RecordViewDelegate {
    
    func recordViewStartRecording(recordView: RecordView) {
        showTimerView()
        setupTimer()
        captureSessionController.startRecording()
    }
    
    func recordViewEndRecording(recordView: RecordView) {
        hideTimerView()
        resetTimer()
        captureSessionController.stopRecording()
    }
    
}

extension CaptureViewController: CaptureSessionControllerDelegate {
    
    func captureSessionControllerFinishedRecording(captureSessionController: CaptureSessionController, outputFileURL: URL) {
        
        movieOutputFileURL = outputFileURL
        
        let player = AVPlayer(url: outputFileURL)
        
        let videoPlayerViewController = VideoPlayerViewController()
        videoPlayerViewController.player = player
        videoPlayerViewController.videoPlayerViewControllerDelegate = self
        
        present(videoPlayerViewController, animated: true) {
            player.play()
        }
        
    }
    
    func captureSessionControllerFailedFinishingRecording(captureSessionController: CaptureSessionController) {
        
        print("failed to finish recording")
        
    }
    
}

extension CaptureViewController: VideoPlayerViewControllerDelegate {
    func videoPlayerViewControllerDismissed(videoPlayerViewController: VideoPlayerViewController) {
        guard let movieOutputFileURL = movieOutputFileURL else { return }
        captureSessionController.cleanUp(outputFileURL: movieOutputFileURL)
    }
}
