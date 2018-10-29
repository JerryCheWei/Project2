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

    var input: YTLiveStreaming!
    var date: Date?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.date = Date()
        let worker = YTLiveStreaming()
        self.input = worker

    }

    @IBAction func liveNowButton(_ sender: Any) {
        input.createBroadcast(titleTextField.text!,
                              description: "\(descriptionTextField.text ?? "")",
                              startTime: self.date!) { (_) in
            print("create broadcast")
        }
    }

}
