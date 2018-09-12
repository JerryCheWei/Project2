//
//  MessageTableViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/24.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit
import Firebase

class MessageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var messageUIView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet var messageTableView: UITableView!
    var textHeightConstraint = NSLayoutConstraint()
    var imageID: String = ""

    func commentInit(_ imageID: String) {
        self.imageID = imageID
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
        self.messageTableView.rowHeight = UITableViewAutomaticDimension

        // textView place holder set
        self.messageTextView.text = "Enter your message ..."
        self.messageTextView.textColor = UIColor.lightGray
        self.textHeightConstraint = self.messageTextView.heightAnchor.constraint(equalToConstant: 30)
        self.textHeightConstraint.isActive = true
        self.adjustTextViewHeight()
        self.sendButton.isEnabled = false
        // fetchMessage
        MessageModel.fetchMessage(messageTableView: self.messageTableView, postImageID: imageID)
        // fetch user image
        self.fetchUserImage()
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
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 270), animated: true)
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        self.adjustTextViewHeight()
        self.sendButton.isEnabled = true
        if self.messageTextView.text.isEmpty {
        self.sendButton.isEnabled = false
        }
        if self.messageTextView.text == "\n" {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            self.messageTextView.resignFirstResponder()
        }
    }

    @IBAction func sendMessageButton(_ sender: Any) {
        Analytics.logEvent("messageVc_SendMessageButton", parameters: nil)
        // send message
        let postImageID = self.imageID
        self.sendMessage(postImageID: postImageID)

        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        self.messageTextView.resignFirstResponder()
        self.messageTextView.text = nil
        if self.messageTextView.text.isEmpty {
            self.messageTextView.text = "Enter your message ..."
            self.messageTextView.textColor = UIColor.lightGray
            self.textHeightConstraint = self.messageTextView.heightAnchor.constraint(equalToConstant: 30)
            self.textHeightConstraint.isActive = true
            self.sendButton.isEnabled = false
            self.messageTableView.reloadData()
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

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MessageModel.allMessage.count
    }

//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if Auth.auth().currentUser?.uid == MessageModel.allMessage[indexPath.row].userID {
//            // delete firebase message
//            if editingStyle == .delete {
//                let ref = Database.database().reference().child("messages").child(imageID)
//                let messageItem = ref.child(MessageModel.allMessage[indexPath.row].key!)
//                messageItem.removeValue()
//            }
//            if editingStyle == .delete {
//                MessageModel.allMessage.remove(at: indexPath.row)
//                tableView.reloadData()
//            }
//        }
//    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if Auth.auth().currentUser?.uid == MessageModel.allMessage[indexPath.row].userID {
            let deleteAction = UIContextualAction(style: .normal, title: "刪除留言") { (action, view, completionHandler) in
                print("delete")
                completionHandler(true)
            }
            deleteAction.backgroundColor = .red
            let request = UIContextualAction(style: .normal, title: "回報") { (action, view, completionHandler) in
                print("回報")
                completionHandler(true)
            }
            let comfiguration = UISwipeActionsConfiguration(actions: [deleteAction, request])
            comfiguration.performsFirstActionWithFullSwipe = false
            return comfiguration
        }
        else {
            let request = UIContextualAction(style: .normal, title: "回報") { (action, view, completionHandler) in
                print("回報")
                completionHandler(true)
            }
            let comfiguration = UISwipeActionsConfiguration(actions: [request])
            comfiguration.performsFirstActionWithFullSwipe = false
            return comfiguration
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
