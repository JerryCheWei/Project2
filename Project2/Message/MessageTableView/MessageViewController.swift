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
    var textHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        let titleID = UserDefaults.standard.string(forKey: "postImageID")
        self.navigationItem.title = titleID
        // user cell xib
        let userNib = UINib(nibName: "MessageTableViewCell", bundle: nil)
        messageTableView.register(userNib, forCellReuseIdentifier: "cell")

        // messageTextField View set
        self.messageUIView.layer.cornerRadius = 20
        self.messageUIView.layer.borderColor = UIColor.gray.cgColor
        self.messageUIView.layer.borderWidth = 1

        // textView place holder set
        self.messageTextView.text = "Enter your message ..."
        self.messageTextView.textColor = UIColor.lightGray
        self.textHeightConstraint = self.messageTextView.heightAnchor.constraint(equalToConstant: 30)
        self.textHeightConstraint.isActive = true
        self.adjustTextViewHeight()
        self.sendButton.isEnabled = false
        // fetchMessage
        MessageModel.fetchMessage(messageTableView: self.messageTableView)
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

    @IBAction func sendButton(_ sender: Any) {
        // send message
        if let postImageID = UserDefaults.standard.string(forKey: "postImageID") {
            self.sendMessage(postImageID: postImageID)
        }

        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        self.messageTextView.resignFirstResponder()
        self.messageTextView.text = nil
        if self.messageTextView.text.isEmpty {
            self.messageTextView.text = "Enter your message ..."
            self.messageTextView.textColor = UIColor.lightGray
            self.textHeightConstraint = self.messageTextView.heightAnchor.constraint(equalToConstant: 30)
            self.textHeightConstraint.isActive = true
            self.sendButton.isEnabled = false
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
        postMessageRef.setValue(["userID": "\(userID)",
                                 "message": self.messageTextView.text] as [AnyHashable: Any])
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MessageModel.allMessage.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MessageTableViewCell
            else {
                fatalError()
        }
        let allMessageItem = MessageModel.allMessage[indexPath.row]

        Database.database().reference().child("users").child(allMessageItem.userID!).observe(.value) { (snapshot) in
                guard
                    let value = snapshot.value as? [String: AnyObject],
                    let name = value["userName"] as? String
                    else {
                        return
                }
                // Message Model
            MessageSet.message(label: cell.userMessageLabel, userName: name, messageText: allMessageItem.message!)
            }
        return cell
    }

}
