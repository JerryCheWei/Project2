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

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var colorView: UIView!
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

    func buttonColor(button: UIButton, lineWidth: CGFloat) {
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: CGPoint.zero, size: button.frame.size)
        gradient.colors = [UIColor.red.cgColor,
                           UIColor.orange.cgColor,
                           UIColor.yellow.cgColor]

        let shape = CAShapeLayer()
        shape.lineWidth = lineWidth
        shape.path = UIBezierPath(roundedRect: button.bounds, cornerRadius: 30).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape

        button.layer.addSublayer(gradient)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.colorSet(view: self.colorView)
//        self.buttonColor(button: self.loginButton, lineWidth: 3)
    }

    let backgroundGradientLayer = CAGradientLayer()

    func colorSet(view: UIView ) {

        backgroundGradientLayer.frame = view.bounds
        let layer = backgroundGradientLayer
        // 為了讓view為半透明
        view.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)

        layer.colors = [
            UIColor(red: 255/255, green: 224/255, blue: 49/255, alpha: 0.2).cgColor,
            UIColor(red: 240/255, green: 69/255, blue: 121/255, alpha: 0.4).cgColor
        ]
        layer.endPoint = CGPoint(x: 1.0, y: 1.0)
        layer.startPoint = CGPoint(x: 0.0, y: 0.0)

        view.layer.insertSublayer(layer, at: 0)
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
