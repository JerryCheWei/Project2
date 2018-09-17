//
//  PostImageViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/9/2.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit
import Firebase
import MessageUI

class PostImageViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var otherFunctionButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    var postImageID: String?
    var userID: String?

    func commendInit(postImageID: String, userID: String) {
        self.postImageID = String()
        self.postImageID = postImageID
        self.userID = userID
    }
    @IBAction func messageButton(_ sender: UIButton) {
        Analytics.logEvent("postImageVc_OpenMessageVcButton", parameters: nil)
        if let messageVC = storyboard?.instantiateViewController(withIdentifier: "messageVC") as? MessageViewController,
            let imageID = self.postImageID ,
            let userID = self.userID {
            messageVC.commentInit(imageID, userID)
            self.navigationController?.pushViewController(messageVC, animated: true)
        }
    }
    @IBAction func otherFunctionButton(_ sender: UIButton) {
        Analytics.logEvent("postImageVc_OtherFunctionButton", parameters: nil)
        if Auth.auth().currentUser?.uid == userID {
            let optionMenu = UIAlertController(title: "刪除", message: "你確定要刪除此貼文？", preferredStyle: .actionSheet)
            let cancleAction = UIAlertAction(title: "取消",
                                             style: .cancel,
                                             handler: nil)
            optionMenu.addAction(cancleAction)

            let deleteAction = UIAlertAction(title: "刪除", style: .destructive) { _ in
                //delete firebase data
                if let postImageID = self.postImageID {
                    //delete storage/images/(postImage.key)
                    DeletePost.deleteStorage(postImageID)
                    //delete postImage/(postImage.key)
                    DeletePost.deleteInPostImage(postImageID)
                    //delete messages/(postImage.key)
                    DeletePost.deleteInMessages(postImageID)
                    //delete users/(userID)/postImages["postImage.key"]
                    DeletePost.deleteInUser(postImageID)
                    self.navigationController?.popViewController(animated: true)
                }
            }
            optionMenu.addAction(deleteAction)

            // iPad
            if let popoverController = optionMenu.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }

            self.present(optionMenu, animated: true, completion: nil)
        }
        else {
            let optionMenu = UIAlertController(title: "檢舉", message: "你確定要檢舉此貼文？", preferredStyle: .actionSheet)
            let cancleAction = UIAlertAction(title: "取消",
                                             style: .cancel,
                                             handler: nil)
            optionMenu.addAction(cancleAction)

            let returns = UIAlertAction(title: "檢舉此貼文", style: .destructive) { (_) in
                print("貼文回報")
                self.sendMail(postImageUserID: self.userID!, postImageID: self.postImageID!)
            }
            optionMenu.addAction(returns)

            // iPad
            if let popoverController = optionMenu.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }

            self.present(optionMenu, animated: true, completion: nil)
        }
    }

    // open email
    func sendMail(postImageUserID: String, postImageID: String) {
        let myController: MFMailComposeViewController = MFMailComposeViewController()
        let userID = "被檢舉者 UserID:\n\(postImageUserID)\n"
        let postImageID = "被檢舉貼文ID:\n\(postImageID)\n"

        if MFMailComposeViewController.canSendMail() {
            myController.mailComposeDelegate = self
            myController.setToRecipients(["jerry.chang0912@gmail.com"])
            myController.setSubject("檢舉貼文回報")
            myController.setMessageBody("\(userID)\n\(postImageID)\n以下請簡短敘述檢舉理由:\n", isHTML: false)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.isNavigationBarHidden = false

        self.fetchImage()
    }

    func fetchImage() {
        if let postImageID = self.postImageID {
            print(postImageID)
            Database.database().reference().child("postImage").child(postImageID).observe(.value) { (snapshot) in
                guard let value = snapshot.value as? [String: Any],
                    let userID = value["userID"] as? String,
                    let postImage = value["postUrl"] as? String
                    else {
                        return
                }
                if let url = URL(string: postImage) {
                    ImageService.getImage(withURL: url, completion: { (image) in
                        self.postImageView.image = image
                    })
                }

                self.userImageView.image = UIImage(named: "iconUserImage")
                self.userImageView.tintColor = .gray
                self.userImageView.backgroundColor = .white
                Database.database().reference().child("users").child(userID).observe(.value, with: { (snapshot) in
                    guard let value = snapshot.value as? [String: Any],
                        let name = value["userName"] as? String
                        else { return }
                    self.userNameLabel.text = name

                    if let userImageUrl = value["userImageUrl"] as? String {
                        if let url = URL(string: userImageUrl) {
                            ImageService.getImage(withURL: url) { (image) in
                                self.userImageView.image = image
                            }
                        }
                    }
                })
            }
        }
    }

}
