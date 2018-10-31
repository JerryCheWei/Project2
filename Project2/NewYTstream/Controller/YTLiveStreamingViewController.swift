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

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!

    var input: YTLiveStreaming = YTLiveStreaming()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func closeStreamVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func liveNowButton(_ sender: Any) {

        if let title = titleTextField.text,
            title.count <= 0 {
            print("請輸入標題")
            Alert.sharedInstance.showEnterTitle(title: "Error", message: "請輸入標題", closeView: self)
        }
        else {
            self.startCreateBroadcast()
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
                }
                else {
                    print("createBroadcast error")
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
