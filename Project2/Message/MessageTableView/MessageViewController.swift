//
//  MessageTableViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/24.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit
import Firebase
import MessageUI

class MessageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var messageViewBottom: NSLayoutConstraint!
    @IBOutlet weak var messageAllView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var messageUIView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet var messageTableView: UITableView!
    var textHeightConstraint = NSLayoutConstraint()
    var imageID: String = ""
    var userID: String = ""

    func commentInit(_ imageID: String, _ userID: String) {
        self.imageID = imageID
        self.userID = userID
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "留言"
        navigationController?.navigationBar.tintColor = .black
        // user cell xib
        let userNib = UINib(nibName: "MessageTableViewCell", bundle: nil)
        messageTableView.register(userNib, forCellReuseIdentifier: "cell")

        // messageTextField View set
        self.messageUIView.layer.cornerRadius = 20
        self.messageUIView.layer.borderColor = UIColor.gray.cgColor
        self.messageUIView.layer.borderWidth = 1

        // table View
        self.messageTableView.estimatedRowHeight = 60
        self.messageTableView.rowHeight = UITableView.automaticDimension

        // textView place holder set
        self.messageTextView.text = "新增留言......"
        self.messageTextView.textColor = UIColor.lightGray
        self.textHeightConstraint = self.messageTextView.heightAnchor.constraint(equalToConstant: 30)
        self.textHeightConstraint.isActive = true
        self.adjustTextViewHeight()
        self.sendButton.isEnabled = false
        // fetchMessage
        MessageModel.fetchMessage(messageTableView: self.messageTableView, postImageID: imageID)
        // fetch user image
        self.fetchUserImage()
        // tap view dismissKeyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        // keyboard set
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // messageTableView 呈現最新 message
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {

            self.moveToBottom()
        }
    }

    @objc func keyboardWillShow(notify: NSNotification) {
            if let userInfo = notify.userInfo,
                let value = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
                let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
                let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {

                let frame = value.cgRectValue
                let intersection = frame.intersection(self.view.frame)
                self.messageViewBottom.constant = intersection.height

                UIView.animate(withDuration: duration, delay: 0.0,
                               options: UIView.AnimationOptions(rawValue: curve), animations: {
                                self.view.layoutIfNeeded()
                                }, completion: nil)
            }
    }
    @objc func keyboardWillHide(notify: NSNotification) {
        if let userInfo = notify.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
            self.messageViewBottom.constant = 0

            UIView.animate(withDuration: duration, delay: 0.0,
                           options: UIView.AnimationOptions(rawValue: curve), animations: {
                            self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        if self.messageTextView.text.isEmpty {
            self.messageTextView.text = "新增留言......"
            self.messageTextView.textColor = UIColor.lightGray
            self.textHeightConstraint = self.messageTextView.heightAnchor.constraint(equalToConstant: 30)
            self.textHeightConstraint.isActive = true
            self.sendButton.isEnabled = false
        }
    }

    func moveToBottom() {
        if MessageModel.allMessage.count > 0 {
            let indexPath = IndexPath(row: MessageModel.allMessage.count - 1, section: 0)

            messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }

    func fetchUserImage() {
        self.userImageView.image = UIImage(named: "iconUserImage")
        self.userImageView.backgroundColor = .white
        self.userImageView.tintColor = .gray
        if let userID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("users").child(userID).observe(.value) { (snapshot) in
                guard
                    let value = snapshot.value as? [String: Any]
                    else { return }
                if let userImageUrl = value["userImageUrl"] as? String {
                    if let url = URL(string: userImageUrl) {
                        ImageService.getImage(withURL: url) { (image) in
                            self.userImageView.image = image
                        }
                    }
                }
            }
        }
    }

    func adjustTextViewHeight() {
        let fixedWidth = self.messageTextView.frame.size.width
        let newSize = self.messageTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        if newSize.height > 80 {
            self.messageTextView.isScrollEnabled = true
        }
        else {
            self.messageTextView.isScrollEnabled = false
            textHeightConstraint.constant = newSize.height
        }
        self.view.layoutSubviews()
    }

    // TextField delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        self.adjustTextViewHeight()
        self.sendButton.isEnabled = true
        if self.messageTextView.text.isEmpty {
        self.sendButton.isEnabled = false
        }
    }

    @IBAction func sendMessageButton(_ sender: Any) {
        Analytics.logEvent("message_send_message_button", parameters: nil)
        // send message
        let postImageID = self.imageID
        self.sendMessage(postImageID: postImageID)

        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        self.messageTextView.resignFirstResponder()
        self.messageTextView.text = nil
        if self.messageTextView.text.isEmpty {
            self.messageTextView.text = "新增留言......"
            self.messageTextView.textColor = UIColor.lightGray
            self.textHeightConstraint = self.messageTextView.heightAnchor.constraint(equalToConstant: 30)
            self.textHeightConstraint.isActive = true
            self.sendButton.isEnabled = false
            self.messageTableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                self.moveToBottom()
            }
        }
    }

    // 送出留言至 Firebase
    func sendMessage(postImageID: String) {
        guard let userID = Auth.auth().currentUser?.uid
            else {
            return
        }
        let messageRef = Database.database().reference().child("messages")
        let postMessageRef = messageRef.child("\(postImageID)").childByAutoId()
        postMessageRef.setValue([
                                "userID": "\(userID)",
                                "message": self.messageTextView.text
                                ] as [AnyHashable: Any])
    }

    // open email
    func sendMail(messageUserID: String, messagesBody: String, key: String) {
        let myController: MFMailComposeViewController = MFMailComposeViewController()
        let userID = "被檢舉者 UserID:\n\(messageUserID)\n"
        let messageBody = "被檢舉留言內容:\n\(messagesBody)\n"
        let messageRef = "檢舉留言貼文ID:\n\(imageID)/\(key)\n"

        if MFMailComposeViewController.canSendMail() {
            myController.mailComposeDelegate = self
            myController.setToRecipients(["jerry.chang0912@gmail.com"])
            myController.setSubject("檢舉留言回報")
            myController.setMessageBody("\(userID)\n\(messageBody)\n\(messageRef) \n以下請簡短敘述檢舉理由:\n", isHTML: false)
            self.present(myController, animated: true, completion: nil)
        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        if result == .sent {
            let successSentAction = UIAlertController(title: "回報送出", message: "已成功送出回報內容，將儘速審核。", preferredStyle: .alert)
            let click = UIAlertAction(title: "確認", style: .cancel, handler: nil)
            successSentAction.addAction(click)
            self.present(successSentAction, animated: true, completion: nil)
        }
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MessageModel.allMessage.count
    }

    // 刪除、回報功能
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if Auth.auth().currentUser?.uid == userID {
            if Auth.auth().currentUser?.uid == MessageModel.allMessage[indexPath.row].userID {
                let deleteAction = UIContextualAction(style: .destructive, title: "刪除留言") { (_ action, _ view, completionHandler) in
                    print("delete")
                    // delete firebase message database
                    let ref = Database.database().reference().child("messages").child(self.imageID)
                    let messageItem = ref.child(MessageModel.allMessage[indexPath.row].key!)
                    messageItem.removeValue()
                    // remove tableView cell
                    MessageModel.allMessage.remove(at: indexPath.row)

                    completionHandler(true)
                }
                deleteAction.backgroundColor = .red
                let comfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
                comfiguration.performsFirstActionWithFullSwipe = false
                return comfiguration
            }
            else {
                let returns = UIContextualAction(style: .normal, title: "回報") { (_ action, _ view, completionHandler) in
                    print("留言回報")
                    completionHandler(true)
                    self.sendMail(messageUserID: MessageModel.allMessage[indexPath.row].userID!, messagesBody: MessageModel.allMessage[indexPath.row].message!, key: MessageModel.allMessage[indexPath.row].key!)
                }
                let comfiguration = UISwipeActionsConfiguration(actions: [returns])
                comfiguration.performsFirstActionWithFullSwipe = false
                return comfiguration
            }
        }
        else {
            if Auth.auth().currentUser?.uid == MessageModel.allMessage[indexPath.row].userID {
                let deleteAction = UIContextualAction(style: .destructive, title: "刪除留言") { (_ action, _ view, completionHandler) in
                    print("delete")
                    // delete firebase message database
                    let ref = Database.database().reference().child("messages").child(self.imageID)
                    let messageItem = ref.child(MessageModel.allMessage[indexPath.row].key!)
                    messageItem.removeValue()
                    // remove tableView cell
                    MessageModel.allMessage.remove(at: indexPath.row)

                    completionHandler(true)
                }
                deleteAction.backgroundColor = .red
                let comfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
                comfiguration.performsFirstActionWithFullSwipe = false
                return comfiguration
            }
            else {
                let returns = UIContextualAction(style: .normal, title: "回報") { (_ action, _ view, completionHandler) in
                    print("回報")
                    completionHandler(true)
                    self.sendMail(messageUserID: MessageModel.allMessage[indexPath.row].userID!, messagesBody: MessageModel.allMessage[indexPath.row].message!, key: MessageModel.allMessage[indexPath.row].key!)
                }
                let comfiguration = UISwipeActionsConfiguration(actions: [returns])
                comfiguration.performsFirstActionWithFullSwipe = false
                return comfiguration
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MessageTableViewCell
            else {
                fatalError()
        }
        let allMessageItem = MessageModel.allMessage[indexPath.row]
        cell.userImageView.image = UIImage(named: "iconUserImage")
        cell.userImageView.backgroundColor = .white
        cell.userImageView.tintColor = .gray

        if let userID = allMessageItem.userID,
            let message = allMessageItem.message {

            cell.userMessageLabel.text = message
            Database.database().reference().child("users").child(userID).observe(.value) { (snapshot) in
                guard
                    let value = snapshot.value as? [String: Any],
                    let name = value["userName"] as? String
                    else { return }
                // Message Model
                cell.userMessageLabel.numberOfLines = 0
                cell.userMessageLabel.attributedText = MessageSet.message(userName: name, messageText: message)
                if let userImageUrl = value["userImageUrl"] as? String {
                    if let url = URL(string: userImageUrl) {
                        ImageService.getImage(withURL: url) { (image) in
                            cell.userImageView.image = image
                        }
                    }
                }
            }
        }

        return cell
    }

}
