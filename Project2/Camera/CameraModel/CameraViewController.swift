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

class CameraViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cameraButton: UIButton!
    var stillImage: UIImage?
    // double tap switch from back to front facing camera
    var toggleCameraGestureRecognizer = UITapGestureRecognizer()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CameraSet.setupCaptureSession()
        CameraSet.checkCamera()
//        CameraSet.setupInputOutput(view: view, cameraButton: cameraButton)
        CameraSet.setupInputOutput(view: self.cameraView, cameraButton: cameraButton)

    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // toggle the Camera
        toggleCameraGestureRecognizer.numberOfTapsRequired = 2
        toggleCameraGestureRecognizer.addTarget(self, action: #selector(toggleCamera))
        view.addGestureRecognizer(toggleCameraGestureRecognizer)
//        self.cameraView.addGestureRecognizer(toggleCameraGestureRecognizer)
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

    @IBAction func shutterButtonDidTap() {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160 ,
                             kCVPixelBufferHeightKey as String: 160
                             ]
        settings.previewPhotoFormat = previewFormat
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

extension CameraViewController: SHViewControllerDelegate {

    func shViewControllerImageDidFilter(image: UIImage) {
        // 取得套用濾鏡後的 image
        let filteredImage: UIImage = image
        if let filterImageData: NSData = UIImageJPEGRepresentation(filteredImage, 0.8) as NSData? {
            UserDefaults.standard.set(filterImageData, forKey: "gatFilterImage")

            print("O ~ Gat filter image in CameraVC")
            let storyboard = UIStoryboard(name: "Camera", bundle: nil)
            if let postImageVC  = storyboard.instantiateViewController(withIdentifier: "SendImageViewController") as? SendImageViewController {
                self.navigationController?.pushViewController(postImageVC, animated: true)
            }
        }
    }

    func shViewControllerDidCancel() {

    }
}
