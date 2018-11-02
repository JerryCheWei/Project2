//
//  YTLiveStreamingViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/10/29.
//  Copyright © 2018 chang-che-wei. All rights reserved.
//

import UIKit
import YTLiveStreaming
import GoogleSignIn

class YTLiveStreamingViewController: UIViewController {

//    @IBOutlet weak var liveNowButton: UIButton!
//    @IBOutlet weak var titleTextField: UITextField!
//    @IBOutlet weak var descriptionTextField: UITextField!
//    var refreshControl: UIActivityIndicatorView!
//
//    var input: YTLiveStreaming = YTLiveStreaming()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        refreshControl = UIActivityIndicatorView()
//        refreshControl.color = .red
//        refreshControl.center.x = view.center.x
//        refreshControl.center.y = view.center.y-100
//        view.addSubview(refreshControl)
//
//        connectLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width-20, height: 50)
//        connectLabel.center.x = view.center.x
//        connectLabel.center.y = view.center.y-40
//        connectLabel.alpha = 0
//        connectLabel.textAlignment = .center
//        view.addSubview(connectLabel)
//
//        // 隱藏TextField
//        titleTextField.isHidden = true
//        descriptionTextField.isHidden = true
//        liveNowButton.isHidden = true
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.startCreateBroadcast()
//        self.loadingView()
//    }
//
//    let connectLabel: UILabel = {
//        let label = UILabel()
//        label.text = "創建直播中..."
//        label.textColor = .white
//        label.font = UIFont.boldSystemFont(ofSize: 20)
//        return label
//    }()
//
//    @IBAction func closeStreamVC(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
//    }
//
////    @IBAction func liveNowButton(_ sender: UIButton) {
////
////        self.startCreateBroadcast()
////        sender.isEnabled = false
////        sender.backgroundColor = .gray
////    }
//
//    func loadingView() {
//        self.refreshControl.startAnimating()
//        UIView.animate(withDuration: 0.8, delay: 0, options: [.repeat, .autoreverse], animations: {
//            self.connectLabel.alpha = 1
//        }, completion: nil)
//    }
//
//    func startCreateBroadcast() {
//        let startDate = Helpers.dateAfter(Date(), after: (hour: 0, minute: 1, second: 0))
//
//        input.createBroadcast("正在 SYOS 進行直播快來看～", description: "", startTime: startDate) { (creatBreadcase) in
//            print(self.titleTextField.text ?? "nil title", self.descriptionTextField.text ?? "nil descriptionTextField")
//            if let breadcast = creatBreadcase {
////                if let LFLiveVC = self.storyboard?.instantiateViewController(withIdentifier: "LFLiveVC") as? LFLiveViewController {
////                    LFLiveVC.into(liveBroadcast: breadcast)
////                    self.navigationController?.pushViewController(LFLiveVC, animated: true)
////                }
//                self.refreshControl.stopAnimating()
//                self.connectLabel.layer.removeAllAnimations()
//            }
//            else {
//                print("createBroadcast error")
//                GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/youtube.readonly")
//                GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/youtube")
//                GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/youtube.force-ssl")
//                GIDSignIn.sharedInstance()?.signInSilently()
//                self.startCreateBroadcast()
//            }
//        }
//    }
//
}
//
//extension YTLiveStreamingViewController: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField == self.titleTextField {
//            self.descriptionTextField.becomeFirstResponder()
//        }
//        if textField == self.descriptionTextField {
//            textField.resignFirstResponder()
//        }
//        return true
//    }
//}
