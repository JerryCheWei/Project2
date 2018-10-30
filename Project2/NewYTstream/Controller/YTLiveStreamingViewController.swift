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
