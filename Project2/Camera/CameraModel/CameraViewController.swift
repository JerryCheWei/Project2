//
//  CameraViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/11.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit
import AVFoundation
import Sharaku
import Firebase

class CameraViewController: UIViewController {

    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cameraButton: UIButton!
    var stillImage: UIImage?
    // double tap switch from back to front facing camera
    var toggleCameraGestureRecognizer = UITapGestureRecognizer()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CameraSet.setupCaptureSession()
        CameraSet.checkCamera()
        CameraSet.setupInputOutput(view: self.cameraView, cameraButton: cameraButton)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // toggle the Camera
        toggleCameraGestureRecognizer.numberOfTapsRequired = 2
        toggleCameraGestureRecognizer.addTarget(self, action: #selector(toggleCamera))
        view.addGestureRecognizer(toggleCameraGestureRecognizer)
    }

    @objc private func toggleCamera() {
        // start the configuration
        print("tap 2 ")
        CameraSet.captureSession.beginConfiguration()

        let newDevice = (CameraSet.currentDevice?.position == .front) ? CameraSet.backFacingCamera : CameraSet.frontFacingCamera

        for input in CameraSet.captureSession.inputs {
            CameraSet.captureSession.removeInput(input)
        }

        let cameraInput: AVCaptureDeviceInput
        do {
            cameraInput = try AVCaptureDeviceInput(device: newDevice!)
        }
        catch let error {
            print(error)
            return
        }

        if CameraSet.captureSession.canAddInput(cameraInput) {
            CameraSet.captureSession.addInput(cameraInput)
        }
        CameraSet.currentDevice = newDevice
        CameraSet.captureSession.commitConfiguration()
    }

    enum CurrentFlashMode {
        case offFlash
        case onFlash
        case autoFlash
    }
    func getSettings(settings: AVCapturePhotoSettings, camera: AVCaptureDevice, flashMode: CurrentFlashMode) -> AVCapturePhotoSettings {

        if camera.hasFlash {
            switch flashMode {
            case .autoFlash: settings.flashMode = .auto
            case .onFlash: settings.flashMode = .on
            default: settings.flashMode = .off
            }
        }
        return settings
    }
    var flash: CurrentFlashMode = .offFlash
    @IBAction func cameraFlashModeButton(_ sender: UIButton) {
        if flash == .offFlash {
            flash = .onFlash
            sender.setImage(UIImage(named: "iconFlashOn"), for: .normal)
        }
        else if flash == .onFlash {
            flash = .autoFlash
            sender.setImage(UIImage(named: "iconFlashAuto"), for: .normal)
        }
        else {
            flash = .offFlash
            sender.setImage(UIImage(named: "iconFlashOff"), for: .normal)
        }
    }

    @IBAction func shutterButtonDidTap() {
        // 模擬器測試用
//        if  let stillImage = UIImage(named: "oliver-plattner-527165-unsplash") {
//            let imageFilterVC = SHViewController(image: stillImage)
//            imageFilterVC.delegate = self
//            //open SHViewControllerVC
//            present(imageFilterVC, animated: true, completion: nil)
//        }

        Analytics.logEvent("camera_click_shutter_button", parameters: nil)
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160 ,
                             kCVPixelBufferHeightKey as String: 160
                             ]
        settings.previewPhotoFormat = previewFormat
        _ = getSettings(settings: settings, camera: CameraSet.currentDevice, flashMode: flash)
       CameraSet.stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension CameraViewController: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            self.stillImage = UIImage(data: imageData)
            if let stillImage = self.stillImage {

                // photoImageFilterVC -> init(image)
                let imageFilterVC = SHViewController(image: stillImage)
                imageFilterVC.delegate = self
                //open SHViewControllerVC
                present(imageFilterVC, animated: true, completion: nil)
            }
        }
    }
}
extension UIImage {
    var isPortrait: Bool {
        return size.height > size.width
    }
    var isLandscape: Bool {
        return size.width > size.height
    }
    var breadth: CGFloat {
        return min(size.width, size.height)
    }
    var breadthSize: CGSize {
        return CGSize(width: breadth, height: breadth)
    }
    var breadthRect: CGRect {
        return CGRect(origin: .zero, size: breadthSize)
    }
    var squared: UIImage? {
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait  ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
        UIImage(cgImage: cgImage).draw(in: breadthRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension CameraViewController: SHViewControllerDelegate {

    func shViewControllerImageDidFilter(image: UIImage) {
        // 取得套用濾鏡後的 image
        if let fixOrientationOfImage: UIImage = fixOrientationOfImage(image: image) {
            let squaredFilteredImage: UIImage = fixOrientationOfImage.squared!
            if let filterImageData: NSData = UIImageJPEGRepresentation(squaredFilteredImage, 0.5) as NSData? {
                UserDefaults.standard.set(filterImageData, forKey: "gatFilterImage")

                print("O ~ Gat filter image in CameraVC")
                let storyboard = UIStoryboard(name: "Camera", bundle: nil)
                if let postImageVC  = storyboard.instantiateViewController(withIdentifier: "SendImageViewController") as? SendImageViewController {
                    self.navigationController?.pushViewController(postImageVC, animated: true)
                }
            }
        }
    }

    func shViewControllerDidCancel() {

    }

    func fixOrientationOfImage(image: UIImage) -> UIImage? {
        if image.imageOrientation == .up {
            return image
        }
        var transform = CGAffineTransform.identity

        switch image.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2))
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by: -CGFloat(Double.pi / 2))
        default:
            break
        }

        switch image.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }

        guard let context = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: 0, space: image.cgImage!.colorSpace!, bitmapInfo: image.cgImage!.bitmapInfo.rawValue) else {
            return nil
        }

        context.concatenate(transform)

        switch image.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
        default:
            context.draw(image.cgImage!, in: CGRect(origin: .zero, size: image.size))
        }
        // And now we just create a new UIImage from the drawing context
        guard let CGImage = context.makeImage() else {
            return nil
        }
        return UIImage(cgImage: CGImage)
    }
}
