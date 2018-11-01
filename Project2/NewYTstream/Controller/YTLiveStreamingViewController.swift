//
//  YTLiveStreamingViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/10/29.
//  Copyright © 2018 chang-che-wei. All rights reserved.
//

import UIKit
import YTLiveStreaming

class YTLiveStreamingViewController: UIViewController {

    @IBOutlet weak var liveNowButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    var refreshControl: UIActivityIndicatorView!

    var input: YTLiveStreaming = YTLiveStreaming()

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIActivityIndicatorView()
        refreshControl.color = .red
        refreshControl.center.x = view.center.x
        refreshControl.center.y = titleTextField.center.y+40
        view.addSubview(refreshControl)
    }

    @IBAction func closeStreamVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func liveNowButton(_ sender: UIButton) {

        if let title = titleTextField.text,
            title.count <= 0 {
            print("請輸入標題")
            Alert.sharedInstance.showEnterTitle(title: "Error", message: "請輸入標題", closeView: self)
        }
        else {
            self.startCreateBroadcast()
            sender.isEnabled = false
            self.refreshControl.startAnimating()
        }
    }

    func startCreateBroadcast() {
        let startDate = Helpers.dateAfter(Date(), after: (hour: 0, minute: 1, second: 0))

        if let title = titleTextField.text,
            let description = descriptionTextField.text {
            input.createBroadcast(title, description: description, startTime: startDate) { (creatBreadcase) in
                print(self.titleTextField.text ?? "nil title", self.descriptionTextField.text ?? "nil descriptionTextField")
                if let breadcast = creatBreadcase {
                    if let LFLiveVC = self.storyboard?.instantiateViewController(withIdentifier: "LFLiveVC") as? LFLiveViewController {
                        LFLiveVC.into(liveBroadcast: breadcast)
                        self.navigationController?.pushViewController(LFLiveVC, animated: true)
                    }
                    self.refreshControl.stopAnimating()
                }
                else {
                    print("createBroadcast error")
                    Alert.sharedInstance.showRetakeToken(title: "重新登入", message: "Youtube 權限已逾時", viewController: self, self.refreshControl, button: self.liveNowButton)
                }
            }
        }
    }

}

extension YTLiveStreamingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.titleTextField {
            self.descriptionTextField.becomeFirstResponder()
        }
        if textField == self.descriptionTextField {
            textField.resignFirstResponder()
        }
        return true
    }
}
