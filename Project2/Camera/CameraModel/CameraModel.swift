//
//  CameraModel.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/11.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class CameraSet {

    static var captureSession = AVCaptureSession()

    //which camera input do we want to use
    static var backFacingCamera: AVCaptureDevice?
    static var frontFacingCamera: AVCaptureDevice?
    // current 目前正在使用哪個 camera
    static var currentDevice: AVCaptureDevice!
    // output device
    static var stillImageOutput: AVCapturePhotoOutput!

    // camera preview layer
    static var cameraPreviewLayer: AVCaptureVideoPreviewLayer!

    static func checkCamera() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)

        for device in deviceDiscoverySession.devices {
            if device.position == .back {
                CameraSet.backFacingCamera = device
            }
            else if device.position == .front {
                CameraSet.frontFacingCamera = device
            }
        }
        // default device
        CameraSet.currentDevice = CameraSet.backFacingCamera
    }

    static func setupCaptureSession() {
        CameraSet.captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }

    static func setupInputOutput(view: UIView, cameraButton: UIButton) {

            DispatchQueue.main.async {
                do {
                    let captureDeviceInput = try AVCaptureDeviceInput(device: CameraSet.currentDevice)

                    if captureSession.canAddInput(captureDeviceInput) {
                        captureSession.addInput(captureDeviceInput)
                    }
                    // configure the session with the output for capturing our still image
                    self.stillImageOutput = AVCapturePhotoOutput()
                    self.stillImageOutput.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
                    if captureSession.canAddOutput(stillImageOutput) {
                        captureSession.addOutput(stillImageOutput)
                    }

                    // set up the camera preview layer
                    cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    view.layer.addSublayer(cameraPreviewLayer)
                    cameraPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    cameraPreviewLayer.frame = view.layer.frame

                    view.bringSubview(toFront: cameraButton)
                    captureSession.startRunning()
                }
                catch let error {
                    print(error)
                }
            }

    }

}
