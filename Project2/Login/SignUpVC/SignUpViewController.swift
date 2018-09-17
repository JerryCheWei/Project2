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

    @IBOutlet weak var backColorView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    let successLogin = "successLogin"

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var confirmPasswordLabel: UILabel!

    @IBAction func backLoginVCButton(_ sender: UIButton) {
        Analytics.logEvent("signUpVc_backLoginVCButton", parameters: nil)
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    let backgroundGradientLayer = CAGradientLayer()
    func colorSet(view: UIView ) {

        backgroundGradientLayer.frame = self.view.frame
        let layer = backgroundGradientLayer
        // 為了讓view為半透明
        view.backgroundColor = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)

        layer.colors = [
            UIColor(red: 240/255, green: 69/255, blue: 121/255, alpha: 0.7).cgColor,
            UIColor(red: 151/255, green: 67/255, blue: 240/255, alpha: 0.8).cgColor
        ]
        layer.startPoint = CGPoint(x: 0.0, y: 0.0)
        layer.endPoint = CGPoint(x: 1.0, y: 1.0)

        view.layer.insertSublayer(layer, at: 0)
    }

    func labelShadowSet(_ label: UILabel) {
        label.shadowOffset = CGSize(width: 1, height: 1)
        label.shadowColor = .black
    }
    func allLabelShadowSet() {
        self.labelShadowSet(self.userNameLabel)
        self.labelShadowSet(self.emailLabel)
        self.labelShadowSet(self.passwordLabel)
        self.labelShadowSet(self.confirmPasswordLabel)
    }

    func textFieldSet(_ textfield: UITextField) {
        textfield.layer.addBorder(edge: .bottom, color: .white, thickness: 1)
    }
    func allTextFieldSet() {
        self.textFieldSet(self.userNameTextField)
        self.textFieldSet(self.emailTextField)
        self.textFieldSet(self.passwordTextField)
        self.textFieldSet(self.confirmPasswordTextField)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        colorSet(view: self.backColorView)
        allLabelShadowSet()
        allTextFieldSet()
        // tap view dismissKeyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        // keyboard set
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    @objc func keyboardWillShow(notify: NSNotification) {

        if let keyboardSize = (notify.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height/3
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
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }

    func clearAllTextField() {
        self.userNameTextField.text = ""
        self.emailTextField.text = ""
        self.passwordTextField.text = ""
        self.confirmPasswordTextField.text = ""
    }
    func loggedin() {
        self.clearAllTextField()
        self.performSegue(withIdentifier: self.successLogin, sender: nil)
    }
    func saveUserInformation() {
        guard let user = Auth.auth().currentUser
            else {
                return
        }
        let usersRef = Database.database().reference().child("users").child(user.uid)
        usersRef.setValue(
            ["userName": self.userNameTextField.text,
             "email": self.emailTextField.text
            ])
    }

    @IBAction func sendButton(_ sender: UIButton) {
        Analytics.logEvent("signUpVc_SendSignUpButton", parameters: nil)
        guard
            let userName = self.userNameTextField.text,
            let email = self.emailTextField.text,
            let password = self.passwordTextField.text,
            let confirmPassword = self.confirmPasswordTextField.text,
            userName.count > 0,
            email.count > 0,
            password.count > 0,
            confirmPassword.count > 0
            else {
                let alertController = UIAlertController(title: "Error", message: "Please enter your name, email and password.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
                return
        }
         if passwordTextField.text != confirmPasswordTextField.text {
            let alertController = UIAlertController(title: "Password Error", message: "Please confirm your password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            Auth.auth().createUser(withEmail: self.emailTextField.text!, password: self.confirmPasswordTextField.text!, completion: { (user, error) in

                if error == nil, user == user {
                    // 已註冊至 Firebase
                    Auth.auth().signIn(withEmail: self.emailTextField.text!,
                                       password: self.passwordTextField.text!, completion: nil)
                    print("success sign up !!!")
                    self.saveUserInformation()
                    self.loggedin()
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
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.userNameTextField {
            self.emailTextField.becomeFirstResponder()
        }
        if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        }
        if textField == self.passwordTextField {
            self.confirmPasswordTextField.becomeFirstResponder()
        }
        if textField == self.confirmPasswordTextField {
            textField.resignFirstResponder()
        }
        return true
    }

//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        if textField == self.passwordTextField {
//            self.scrollView.setContentOffset(CGPoint(x: 0, y: 50), animated: true)
//        }
//        else if textField == self.confirmPasswordTextField {
//             self.scrollView.setContentOffset(CGPoint(x: 0, y: 150), animated: true)
//        }
//        else {
//            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
//
//        }
//    }
//    func textFieldDidEndEditing(_ textField: UITextField) {
//         self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
//    }
}

extension CALayer {
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        let borders = CALayer()

        switch edge {
        case .top:
            borders.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case .bottom:
            borders.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
        case .left:
            borders.frame = CGRect(x: 0, y: 0 + thickness, width: thickness, height: frame.height - thickness * 2)
        case .right:
            borders.frame = CGRect(x: frame.width - thickness, y: 0 + thickness, width: thickness, height: frame.height - thickness * 2)
        default:
            break
        }

        borders.backgroundColor = color.cgColor

        self.addSublayer(borders)
    }
}
