//
//  LoginViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/22.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    let signUpVC = "signupVC"

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBAction func signUpButton(_ sender: UIButton) {
        sender.addTarget(self, action: #selector(openSignUpVC), for: .touchUpInside)
    }
    @objc func openSignUpVC() {
       guard let singupVC = storyboard?.instantiateViewController(withIdentifier: signUpVC)
        else {
            return
        }
        present(singupVC, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
