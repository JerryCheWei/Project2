//
//  LoginViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/22.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit
import Firebase

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

    }

    @IBAction func loginButton(_ sender: UIButton) {

        if self.emailTextField.text == "" || self.passwordTextField.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)

            self.present(alertController, animated: true, completion: nil)
        }
        else {
            Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                if error == nil {
                    print("successfully logged in !")
                    // 跳到 HomeVC
                }
                else if user == nil, let error = error {
                    let alertController = UIAlertController(title: "Error",
                                                        message: error.localizedDescription,
                                                        preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK",
                                                    style: .cancel,
                                                    handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }

    }
}
