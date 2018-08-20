//
//  SendImageViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/19.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit
import Firebase

class SendImageViewController: UIViewController {

    var filterImage: UIImage?
    @IBOutlet weak var sendImageView: UIImageView!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    // Database Ref
    let imageIdRef = Database.database().reference().child("postImage").childByAutoId()
    // 上傳進度條
    let progressView: UIProgressView = {
        // 建立一個 UIProgressView
        let myProgressView = UIProgressView(progressViewStyle: .default)

        // UIProgressView 的進度條顏色
        myProgressView.progressTintColor = UIColor.blue

        // UIProgressView 進度條尚未填滿時底下的顏色
        myProgressView.trackTintColor = UIColor.white

        // 設置尺寸與位置並放入畫面中
        let fullScreenSize = UIScreen.main.bounds.size
        myProgressView.frame = CGRect(x: 0, y: 0, width: fullScreenSize.width * 0.8, height: 50)
        myProgressView.center = CGPoint(x: fullScreenSize.width * 0.5, y: fullScreenSize.height * 0.8)

        return myProgressView
    } ()

    func uploadImageToFirebaseStorage(data: Data) {
        // firebase storage
        let storageRef = Storage.storage().reference()
        // Create a reference to the file you want to upload
        let riversRef = storageRef.child("images").child("\(imageIdRef.key).jpg")
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"

        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = riversRef.putData(data, metadata: uploadMetadata) { (metadata, error) in
            if let error = error {
                print("I recevied an error \(String(describing: error.localizedDescription))")
            } else {
                print("UPload complete! Here's some metadata: \(String(describing: metadata))")
            }

            // You can also access to download URL after upload.
            riversRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("Uh-oh, an error occurred! \(String(describing: error))")
                    return
                }
                print("downloadURL: \(downloadURL)")
                self.progressView.isHidden = true
                self.uploadPostImage(imageURL: downloadURL)
                self.uploadDoneDismissView()
            }
        }

        // update progressView
        uploadTask.observe(.progress) { [weak self] (snapshot) in
            guard let storageSelf = self else { return }
            guard let progress = snapshot.progress else { return }
            storageSelf.progressView.progress = Float(progress.fractionCompleted)
        }

    }

    func uploadPostImage(imageURL: URL) {

        self.imageIdRef.setValue("\(imageURL)")

    }

    // 取消分享頁面
    func uploadDoneDismissView() {
        print("dismiss post View")
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let imageData = UserDefaults.standard.object(forKey: "gatFilterImage") as? Data {
            self.filterImage = UIImage(data: imageData)
            sendImageView.image = filterImage

        }
    }

    @IBAction func sendButton(_ sender: UIBarButtonItem) {

        // 重設進度條
        progressView.progress = 0
        scrollView.addSubview(progressView)

        if let imageData = UserDefaults.standard.object(forKey: "gatFilterImage") as? Data {
            uploadImageToFirebaseStorage(data: imageData)
        }

    }
}