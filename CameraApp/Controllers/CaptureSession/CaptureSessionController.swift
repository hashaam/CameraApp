//
//  CaptureSessionController.swift
//  BecomeAPresenter
//
//  Created by HC Studios on 8/21/20.
//  Copyright © 2020 HC Studios. All rights reserved.
//

import Foundation
import AVFoundation

enum CameraType {
    case ultrawide
    case wide
    case telephoto
}

enum CameraPosition {
    case front
    case back
}

typealias CaptureSessionInitializedCompletionHandler = () -> Void
typealias CaptureSessionToggleCompletionHandler = (CameraPosition) -> Void

protocol CaptureSessionControllerDelegate: AnyObject {
    func captureSessionControllerFinishedRecording(captureSessionController: CaptureSessionController, outputFileURL: URL)
    func captureSessionControllerFailedFinishingRecording(captureSessionController: CaptureSessionController)
}

class CaptureSessionController: NSObject {
    
    private lazy var captureSession = AVCaptureSession()
    private var captureDevice: AVCaptureDevice?
    private var captureDeviceInput: AVCaptureDeviceInput?
    private var zoomState = ZoomState.wide
    
    private var cameraPosition = CameraPosition.back
    
    private var previousZoomState = ZoomState.wide
    
    private var movieFileOutput: AVCaptureMovieFileOutput?
    
    weak var delegate: CaptureSessionControllerDelegate?
    
    override init() {
        super.init()
        captureDevice = getBackVideoCaptureDevice()
    }
    
    func getCaptureSession() -> AVCaptureSession {
        return captureSession
    }
    
    func setZoomState(zoomState: ZoomState) {
        self.zoomState = zoomState
        setVideoZoomFactor()
    }
    
    func getCameraTypes() -> [CameraType]? {
        guard let captureDevice = captureDevice else { return nil }
        switch captureDevice.deviceType {
        case .builtInTripleCamera:
            return [.ultrawide, .wide, .telephoto]
        case .builtInDualWideCamera:
            return [.ultrawide, .wide]
        case .builtInDualCamera:
            return [.wide, .telephoto]
        case .builtInWideAngleCamera:
            return [.wide]
        default:
            return nil
        }
    }
    
    func toggleCamera(completionHandler: CaptureSessionToggleCompletionHandler? = nil) {
        if let captureDeviceInput = captureDeviceInput {
            captureSession.removeInput(captureDeviceInput)
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            switch self.cameraPosition {
            case .back:
                self.previousZoomState = self.zoomState
                self.zoomState = .wide 
                if let frontCaptureDevice = self.getFrontVideoCaptureDevice() {
                    self.initializeCaptureSession(captureDevice: frontCaptureDevice)
                }
                self.cameraPosition = .front
                
            case .front:
                if let backCaptureDevice = self.getBackVideoCaptureDevice() {
                    self.initializeCaptureSession(captureDevice: backCaptureDevice)
                }
                self.cameraPosition = .back
                self.zoomState = self.previousZoomState
                self.setVideoZoomFactor()
            }
            
            self.resetFocus()
            
            completionHandler?(self.cameraPosition)
        }
    }
    
    func initializeCaptureSession(captureDevice: AVCaptureDevice? = nil, completionHandler: CaptureSessionInitializedCompletionHandler? = nil) {
        
        var tmpCaptureDevice = self.captureDevice
        
        if let passedCaptureDevice = captureDevice {
            tmpCaptureDevice = passedCaptureDevice
        }
        
        guard let captureDevice = tmpCaptureDevice else { return }
        self.captureDevice = captureDevice
        guard let captureDeviceInput = getCaptureDeviceInput(captureDevice: captureDevice) else { return }
        self.captureDeviceInput = captureDeviceInput
        guard captureSession.canAddInput(captureDeviceInput) else { return }
        
        NotificationCenter.default.removeObserver(
            self,
            name: .AVCaptureDeviceSubjectAreaDidChange,
            object: captureDevice
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(subjectAreaDidChangeNotificationHandler(notification:)),
            name: .AVCaptureDeviceSubjectAreaDidChange,
            object: captureDevice
        )
        
        captureSession.addInput(captureDeviceInput)
        
        let movieFileOutput = AVCaptureMovieFileOutput()
        guard captureSession.canAddOutput(movieFileOutput) else { return }
        captureSession.beginConfiguration()
        captureSession.addOutput(movieFileOutput)
        captureSession.sessionPreset = .high
        
        if let connection = movieFileOutput.connection(with: .video),
           connection.isVideoStabilizationSupported {
            connection.preferredVideoStabilizationMode = .auto
        }
        
        captureSession.commitConfiguration()
        self.movieFileOutput = movieFileOutput
        
        captureSession.startRunning()
        setVideoZoomFactor()
        completionHandler?()
    }
    
    func stopRunning() {
        captureSession.stopRunning()
    }
    
    func startRunning() {
        captureSession.startRunning()
    }
    
    func setFocus(focusMode: AVCaptureDevice.FocusMode,
                  exposureMode: AVCaptureDevice.ExposureMode,
                  atPoint devicePoint: CGPoint,
                  shouldMonitorSubjectAreaChange: Bool) {
        
        guard let captureDevice = captureDevice else { return }
        
        do {
            try captureDevice.lockForConfiguration()
        } catch let error as NSError {
            print("failed to get lock for configuration on capture device with error \(error)")
            return
        }
        
        if captureDevice.isFocusPointOfInterestSupported, captureDevice.isFocusModeSupported(focusMode) {
            captureDevice.focusPointOfInterest = devicePoint
            captureDevice.focusMode = focusMode
        }
        
        if captureDevice.isExposurePointOfInterestSupported, captureDevice.isExposureModeSupported(exposureMode) {
            captureDevice.exposurePointOfInterest = devicePoint
            captureDevice.exposureMode = exposureMode
        }
        
        captureDevice.isSubjectAreaChangeMonitoringEnabled = shouldMonitorSubjectAreaChange
        captureDevice.unlockForConfiguration()
        
    }
    
    @objc func subjectAreaDidChangeNotificationHandler(notification: Notification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        setFocus(
            focusMode: .continuousAutoFocus,
            exposureMode: .continuousAutoExposure,
            atPoint: devicePoint,
            shouldMonitorSubjectAreaChange: false
        )
    }
    
    func turnOnTorch() -> Bool {
        return setTorchMode(torchMode: .on)
    }
    
    func turnOffTorch() -> Bool {
        return setTorchMode(torchMode: .off)
    }
    
    func startRecording() {
        guard let movieFileOutput = movieFileOutput else { return }
        
        guard let interfaceOrientation = AppSetup.interfaceOrientation else { return }
        guard let videoOrientation = VideoOrientationController.getVideoOrientation(interfaceOrientation: interfaceOrientation) else { return }
        
        let movieFileOutputConnection = movieFileOutput.connection(with: .video)
        movieFileOutputConnection?.videoOrientation = videoOrientation
        
        let availableVideoCodecTypes = movieFileOutput.availableVideoCodecTypes
        if availableVideoCodecTypes.contains(.hevc) {
            movieFileOutput.setOutputSettings([
                AVVideoCodecKey: AVVideoCodecType.hevc
            ], for: movieFileOutputConnection!)
        }
        
        let outputFileName = UUID().uuidString
        let outputFilePath = (NSTemporaryDirectory() as NSString)
            .appendingPathComponent((outputFileName as NSString)
                .appendingPathExtension("mov")!)
        let outputURL = URL(fileURLWithPath: outputFilePath)
        movieFileOutput.startRecording(to: outputURL, recordingDelegate: self)
        
    }
    
    func stopRecording() {
        guard let movieFileOutput = movieFileOutput else { return }
        movieFileOutput.stopRecording()

    }
    
    var isRecording: Bool {
        guard let movieFileOutput = movieFileOutput else { return false }
        return movieFileOutput.isRecording
    }
    
    func cleanUp(outputFileURL: URL) {
        let path = outputFileURL.path
        guard FileManager.default.fileExists(atPath: path) else { return }
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch {
            print("Could not remove file at url: \(outputFileURL)")
        }
    }
    
}

private extension CaptureSessionController {
    func getBackVideoCaptureDevice() -> AVCaptureDevice? {
        
        if let tripleCamera = AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: .back) {
            return tripleCamera
        }
        
        if let dualWideCamera = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) {
            return dualWideCamera
        }
        
        if let dualCamera = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return dualCamera
        }
        
        if let wideAngleCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return wideAngleCamera
        }
        
        return nil
        
    }
    
    func getFrontVideoCaptureDevice() -> AVCaptureDevice? {
        
        if let trueDepthCamera = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front) {
            return trueDepthCamera
        }
        
        if let wideAngleCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            return wideAngleCamera
        }
        
        return nil
        
    }
    
    func getCaptureDeviceInput(captureDevice: AVCaptureDevice) -> AVCaptureDeviceInput? {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            return captureDeviceInput
        } catch let error {
            print("Failed to get capture device input with error \(error)")
        }
        return nil
    }
    
    func setVideoCaptureDeviceZoom(videoZoomFactor: CGFloat, animated: Bool = false, rate: Float = 0) {
        guard let captureDevice = captureDevice else { return }
        do {
            try captureDevice.lockForConfiguration()
        } catch let error {
            print("Failed to get lock configuration on capture device with error \(error)")
            return
        }
        if animated {
            captureDevice.ramp(toVideoZoomFactor: videoZoomFactor, withRate: rate)
        } else {
            captureDevice.videoZoomFactor = videoZoomFactor
        }
        captureDevice.unlockForConfiguration()
    }
    
    func getVideoZoomFactor() -> CGFloat {
        switch zoomState {
        case .ultrawide:
            return 1
        case .wide:
            return getWideVideoZoomFactor()
        case .telephoto:
            return getTelephotoVideoZoomFactor()
        }
    }
    
    func getWideVideoZoomFactor() -> CGFloat {
        guard let captureDevice = captureDevice else { return 1 }
        switch captureDevice.deviceType {
        case .builtInTripleCamera:
            return 2
        case .builtInDualWideCamera:
            return 2
        default:
            return 1
        }
    }
    
    func getTelephotoVideoZoomFactor() -> CGFloat {
        guard let captureDevice = captureDevice else { return 2 }
        switch captureDevice.deviceType {
        case .builtInTripleCamera:
            return 3
        case .builtInDualCamera:
            return 2
        default:
            return 2
        }
    }
    
    func setVideoZoomFactor() {
        let videoZoomFactor = getVideoZoomFactor()
        setVideoCaptureDeviceZoom(videoZoomFactor: videoZoomFactor)
    }
    
    func setTorchMode(torchMode: AVCaptureDevice.TorchMode) -> Bool {
        guard let captureDevice = captureDevice else { return false }
        do {
            try captureDevice.lockForConfiguration()
        } catch let error as NSError {
            print("failed to get lock for configuration on capture device with error \(error)")
        }
        guard captureDevice.isTorchAvailable else { return false }
        captureDevice.torchMode = torchMode
        captureDevice.unlockForConfiguration()
        return true
    }
    
    func resetFocus() {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        setFocus(
            focusMode: .continuousAutoFocus,
            exposureMode: .continuousAutoExposure,
            atPoint: devicePoint,
            shouldMonitorSubjectAreaChange: false
        )
    }
    
}

extension CaptureSessionController: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
    
        var success = true
        
        if let error = error as? NSError {
            success = (error.userInfo[AVErrorRecordingSuccessfullyFinishedKey] as AnyObject).boolValue
        }
        
        if success {
            delegate?.captureSessionControllerFinishedRecording(
                captureSessionController: self,
                outputFileURL: outputFileURL
            )
        } else {
            delegate?.captureSessionControllerFailedFinishingRecording(captureSessionController: self)
            cleanUp(outputFileURL: outputFileURL)
        }
        
    }
    
}
