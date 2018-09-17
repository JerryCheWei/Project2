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

    @IBOutlet weak var signVCButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var colorView: UIView!
    let signUpVC = "signUpVC"
    let successLogin = "successLogin"
    let emailImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 24))
    let passwordImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 24))
    let emailImage = UIImage(named: "round_local_post_office_white_24pt")
    let passwordImage = UIImage(named: "round_lock_white_24pt")

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBAction func openSignUpVCButton(_ sender: UIButton) {
//        sender.addTarget(self, action: #selector(openSignUpVC), for: .touchUpInside)
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

    func textFieldSet(_ textfield: UITextField) {
        textfield.layer.addBorder(edge: .bottom, color: .white, thickness: 1)
    }
    func allTextFieldSet() {
        self.textFieldSet(self.emailTextField)
        self.textFieldSet(self.passwordTextField)

        // leftImageView
        self.emailTextField.leftViewMode = UITextFieldViewMode.always
        self.passwordTextField.leftViewMode = UITextFieldViewMode.always
        emailImageView.tintColor = .white
        emailImageView.contentMode = .scaleAspectFit
        passwordImageView.tintColor = .white
        passwordImageView.contentMode = .scaleAspectFit
        emailImageView.image =  self.emailImage
        self.emailTextField.leftView = emailImageView
        passwordImageView.image =  self.passwordImage
        self.passwordTextField.leftView = passwordImageView
    }

// Button 漸層外框
//    func buttonColor(button: UIButton, lineWidth: CGFloat) {
//        let gradient = CAGradientLayer()
//        gradient.frame =  CGRect(origin: CGPoint.zero, size: button.frame.size)
//        gradient.colors = [UIColor.red.cgColor,
//                           UIColor.yellow.cgColor,
//                           UIColor.orange.cgColor]
//
//        let shape = CAShapeLayer()
//        shape.lineWidth = lineWidth
//        shape.path = UIBezierPath(roundedRect: button.bounds, cornerRadius: 12).cgPath
//        shape.strokeColor = UIColor.black.cgColor
//        shape.fillColor = UIColor.clear.cgColor
//        gradient.mask = shape
//
//        button.layer.addSublayer(gradient)
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.colorSet(view: self.colorView)
        // tap view dismissKeyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        // keyboard set
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

//        self.buttonColor(button: self.loginButton, lineWidth: 5)
        self.signVCButton.layer.borderWidth = 2
        self.signVCButton.layer.borderColor = UIColor.white.cgColor

        self.allTextFieldSet()
    }

    @objc func keyboardWillShow(notify: NSNotification) {

        if let keyboardSize = (notify.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height/2
            }
        }
    }
    @objc func keyboardWillHide(notify: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    let backgroundGradientLayer = CAGradientLayer()

    func colorSet(view: UIView ) {

        backgroundGradientLayer.frame = view.bounds
        let layer = backgroundGradientLayer
        // 為了讓view為半透明
        view.backgroundColor = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)

        layer.colors = [
            UIColor(red: 0/255, green: 189/255, blue: 130/255, alpha: 0.7).cgColor,
            UIColor(red: 57/255, green: 102/255, blue: 224/255, alpha: 0.8).cgColor
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
