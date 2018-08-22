//
//  SignUpViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/22.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!

    @IBAction func loginVC(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func sendButton(_ sender: UIButton) {
        if userNameTextField.text == "" ||
            emailTextField.text == "" ||
            passwordTextField.text == "" ||
            confirmPasswordTextField.text == "" {

            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)

            self.present(alertController, animated: true, completion: nil)
        }
        else if passwordTextField.text == confirmPasswordTextField.text {
            Auth.auth().createUser(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion: { (user, error) in

                if error == nil, user == user {
                    Auth.auth().signIn(withEmail: self.emailTextField.text!,
                                       password: self.passwordTextField.text!, completion: nil)
                    print("success sign up !!!")
                }
                if let error = error {
                    // 註冊錯誤警告
                    let alert = UIAlertController(title: "Sign Up Failed",
                                                  message: error.localizedDescription,
                                                  preferredStyle: .alert)

                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
        else if passwordTextField.text != confirmPasswordTextField.text {
            let alertController = UIAlertController(title: "Password Error", message: "Please confirm your password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)

            self.present(alertController, animated: true, completion: nil)
        }

    }

}
