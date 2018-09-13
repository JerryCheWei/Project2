//
//  HomeViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/19.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit
import Firebase
import MessageUI

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var homeCollectionView: UICollectionView!

    var postImages = [PostImage]()

    func fetchImage() {

        Database.database().reference().child("postImage").observe(.value) { (snapshot) in
            var loadPostImage = [PostImage]()
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let loadPostImageItem = PostImage.init(snapshot: snapshot) {
                        loadPostImage.append(loadPostImageItem)
                }
            }
            self.postImages = loadPostImage.reversed()
            self.homeCollectionView.reloadData()
        }

    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? NewHomeCollectionViewCell
            else {
                fatalError()
        }
        let postImage = self.postImages[indexPath.row]

        cell.postImageView.image = nil
        cell.userImageView.image = UIImage(named: "iconUserImage")
        cell.userImageView.tintColor = .gray
        cell.userImageView.backgroundColor = .white

        if let url = URL(string: postImage.postUrl!) {
            ImageService.getImage(withURL: url) { (image) in
                cell.postImageView.image = image
            }
        }
        Database.database().reference().child("users").child(postImage.userID!).observe(.value) { (snapshot) in
            guard
                let value = snapshot.value as? [String: Any],
                let name = value["userName"] as? String
                else {
                    return
            }
            cell.userNameButton.setTitle(name, for: .normal)

            if let userImageUrl = value["userImageUrl"] as? String {
                if let url = URL(string: userImageUrl) {
                    ImageService.getImage(withURL: url) { (image) in
                        cell.userImageView.image = image
                    }
                }
            }
        }

        Database.database().reference().child("messages").child(postImage.idName!).observe(.value) { (snapshot) in
            var loadMessage = [String]()
            var names = [String]()
                loadMessage.removeAll()
                for child in snapshot.children.allObjects {
                    if let snapshot = child as? DataSnapshot {
                        guard
                            let value = snapshot.value as? [String: Any],
                            let message = value["message"] as? String,
                            let userID = value["userID"] as? String
                            else {
                                return
                        }
                        loadMessage.append(message)
                        Database.database().reference().child("users").child(userID).observe(.value, with: { (snapshot) in
                            guard
                            let value = snapshot.value as? [String: Any],
                            let name = value["userName"] as? String
                                else {
                                    return
                            }
                            names.append(name)
                            cell.messageLabel.attributedText = MessageSet.message(userName: names[0], messageText: loadMessage[0])
                        })
                    }
            }
        }

        // CellDelegate Protocol delegate
        cell.deleggate = self
        cell.indexPath = indexPath
        cell.messageLabel.text = "\n"

        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchImage()
        // set collcetion cell xib
        let nib = UINib.init(nibName: "NewHomeCollectionViewCell", bundle: nil)
        homeCollectionView.register(nib, forCellWithReuseIdentifier: "cell")
        if let flowLayout = homeCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        homeCollectionView.reloadData()
    }
}

extension HomeViewController: CellDelegateProtocol {
    func userNameButton(indexPath: Int) {
        Analytics.logEvent("homeVc_ClickUserNameButton", parameters: nil)
        if Auth.auth().currentUser?.uid == postImages[indexPath].userID {
            if let userVC = storyboard?.instantiateViewController(withIdentifier: "userVC") as? NewUserViewController {
                self.navigationController?.pushViewController(userVC, animated: true)
            }
        }
        else {
            if let otherUserVC = storyboard?.instantiateViewController(withIdentifier: "otherUserVC") as? OtherUserViewController,
                let userID = postImages[indexPath].userID {
                otherUserVC.commentInit(userID)
                self.navigationController?.pushViewController(otherUserVC, animated: true)
            }
        }
    }
    func passData(indexPath: Int) {
        Analytics.logEvent("homeVc_ClickMessageButton", parameters: nil)
       if  let messageVC = storyboard?.instantiateViewController(withIdentifier: "messageVC") as? MessageViewController,
        let imageID = postImages[indexPath].idName ,
        let postUserID = postImages[indexPath].userID {
            messageVC.commentInit(imageID, postUserID)
            self.navigationController?.pushViewController(messageVC, animated: true)
        }
    }

    func otherFunctionPassData(indexPath: Int) {
        Analytics.logEvent("homeVc_ClickOtherFunctionButton", parameters: nil)
        if Auth.auth().currentUser?.uid == postImages[indexPath].userID {
            let optionMenu = UIAlertController(title: "刪除", message: "你確定要刪除此貼文？", preferredStyle: .actionSheet)
            let cancleAction = UIAlertAction(title: "取消",
                                             style: .cancel,
                                             handler: nil)
            optionMenu.addAction(cancleAction)

            let deleteAction = UIAlertAction(title: "刪除", style: .destructive) { _ in
                //delete firebase data
                if let postImageID = self.postImages[indexPath].idName {
                    //delete storage/images/(postImage.key)
                    DeletePost.deleteStorage(postImageID)
                    //delete postImage/(postImage.key)
                    DeletePost.deleteInPostImage(postImageID)
                    //delete messages/(postImage.key)
                    DeletePost.deleteInMessages(postImageID)
                    //delete users/(userID)/postImages["postImage.key"]
                    DeletePost.deleteInUser(postImageID)
                }
            }
            optionMenu.addAction(deleteAction)

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
                self.sendMail(postImageUserID: self.postImages[indexPath].userID!, postImageID: self.postImages[indexPath].idName!)
            }
            optionMenu.addAction(returns)
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
}

class PostImage {
    let idName: String?
    let postUrl: String?
    let userID: String?

    init(idName: String, postUrl: String, userID: String) {
        self.idName = idName
        self.postUrl = postUrl
        self.userID = userID
    }

    init?(snapshot: DataSnapshot) {
        guard
        let value = snapshot.value as? [String: AnyObject],
        let idName = value["idName"] as? String,
        let postUrl = value["postUrl"] as? String,
        let userID = value["userID"] as? String
            else {
                return nil
        }

        self.idName = idName
        self.postUrl = postUrl
        self.userID = userID
    }

}
