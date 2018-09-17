//
//  UserPrivacyViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/9/10.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit

class UserPrivacyViewController: UIViewController {

    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var disagreeButton: UIButton!
    let signUpVC = "signUpVC"

    @IBAction func agreeButtonAction(_ sender: UIButton) {
         self.performSegue(withIdentifier: signUpVC, sender: nil)
    }

    @IBAction func disagree(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "使用者隱私權條款"
        navigationController?.navigationBar.tintColor = .black
    }

}
