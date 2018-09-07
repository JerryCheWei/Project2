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
    let successLogin = "successLogin"

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBAction func openSignUpVCButton(_ sender: UIButton) {
        sender.addTarget(self, action: #selector(openSignUpVC), for: .touchUpInside)
        Analytics.logEvent("loginVc_openSignUpVCButton", parameters: nil)
    }

    @objc func openSignUpVC() {
        self.performSegue(withIdentifier: self.signUpVC, sender: nil)
    }
    func loggedin() {
        self.clearAllTextField()
        self.performSegue(withIdentifier: self.successLogin, sender: nil)
    }
    func clearAllTextField() {
        self.emailTextField.text = ""
        self.passwordTextField.text = ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Hi ")
    }

    @IBAction func loginButton(_ sender: UIButton) {
        Analytics.logEvent("loginVc_loginButton", parameters: nil)
        guard
            let email = self.emailTextField.text,
            let password = self.passwordTextField.text,
            email.count > 0,
            password.count > 0
        else {
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
            Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                if error == nil {
                    print("successfully logged in !")
                    // 跳到 Home View
                    self.loggedin()
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

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        }
        if textField == self.passwordTextField {
            textField.resignFirstResponder()
        }
        return true
    }
}
