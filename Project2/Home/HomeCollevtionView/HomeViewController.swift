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
import YTLiveStreaming
import GoogleSignIn

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MFMailComposeViewControllerDelegate {

    @IBAction func goLiveVCButton(_ sender: UIButton) {
        guard let liveVC = storyboard?.instantiateViewController(withIdentifier: "YTStreaming") else {
            return
        }
        present(liveVC, animated: true, completion: nil)
    }
    @IBOutlet weak var homeCollectionView: UICollectionView!
    let userID = Auth.auth().currentUser?.uid
    var postImages = [PostImage]()
    var dismissValue = [String]()

    func fetchImage() {

        if let userID = self.userID {
            // 1
            Database.database().reference().child("postImage").observe(.value) { (snapshot) in
                var posts = [String]()

                for childs in snapshot.children {
                    if let child = childs as? DataSnapshot {
                        posts.append(child.key)
                        print("~~~~~~~~~~~~~~~~~~ \(posts)")
                    }
                    Database.database().reference().child("dismiss").child(userID).observe(.value, with: { (snapshot) in
                        self.dismissValue.removeAll()
                        guard let value = snapshot.value as? [String]
                            else {
                                Database.database().reference().child("postImage").observe(.value) { (snapshot) in
                                    var loadPostImage = [PostImage]()
                                    for child in snapshot.children {
                                        if let snapshot = child as? DataSnapshot,
                                            let loadPostImageItem = PostImage.init(snapshot: snapshot) {
                                                loadPostImage.append(loadPostImageItem)
                                        }
                                        self.postImages = loadPostImage.reversed()
                                        self.homeCollectionView.reloadData()
                                    }
                                    self.refreshControl.endRefreshing()
                                }
                                return
                        }

                        self.dismissValue = value
                        var dismiss = posts

                        for postID in value {
                            dismiss = dismiss.filter { $0 != "\(postID)"}
                            print("dismiss~~~~~~~~~~~~~~~~~~ \(dismiss)")
                        }
                        var loadPostImage = [PostImage]()
                        for postImage in dismiss {
                            Database.database().reference().child("postImage").child(postImage).observe(.value) { (snapshot) in
                                if let loadPostImageItem = PostImage.init(snapshot: snapshot) {
                                    loadPostImage.append(loadPostImageItem)
                                }
                                self.postImages = loadPostImage.reversed()
                                self.homeCollectionView.reloadData()
                            }
                        }
                        self.refreshControl.endRefreshing()
                    })
                }
            }
        }

//        Database.database().reference().child("postImage").observe(.value) { (snapshot) in
//            var loadPostImage = [PostImage]()
//            for child in snapshot.children {
//                if let snapshot = child as? DataSnapshot,
//                    let loadPostImageItem = PostImage.init(snapshot: snapshot) {
//                        loadPostImage.append(loadPostImageItem)
//                }
//                self.postImages = loadPostImage.reversed()
//                self.homeCollectionView.reloadData()
//            }
//        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("postImages.count ~~~~~~~~~~~ \(postImages.count)")
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
        #warning("TODO: cell 自動調整踏小顯示問題")
//        if let flowLayout = homeCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
//        }

        let accessToken = UserDefaults.standard.string(forKey: "accessToken")
        GoogleOAuth2.sharedInstance.accessToken = accessToken
        print("accessToken: \(accessToken ?? "no get token")")

        refreshControl = UIRefreshControl()
        homeCollectionView.addSubview(refreshControl)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        homeCollectionView.reloadData()
    }

    var refreshControl: UIRefreshControl!

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl.isRefreshing {
            fetchImage()
        }
    }
}

extension HomeViewController: CellDelegateProtocol {
    func userNameButton(indexPath: Int) {
        Analytics.logEvent("home_click_user_name_button", parameters: nil)
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
        Analytics.logEvent("home_click_message_button", parameters: nil)
       if  let messageVC = storyboard?.instantiateViewController(withIdentifier: "messageVC") as? MessageViewController,
        let imageID = postImages[indexPath].idName ,
        let postUserID = postImages[indexPath].userID {
            messageVC.commentInit(imageID, postUserID)
            self.navigationController?.pushViewController(messageVC, animated: true)
        }
    }

    func otherFunctionPassData(indexPath: Int) {
        Analytics.logEvent("home_click_other_function_button", parameters: nil)
        if Auth.auth().currentUser?.uid == postImages[indexPath].userID {
            let optionMenu = UIAlertController(title: "刪除", message: "你確定要刪除此貼文？\n刪除後將無法復原此貼文。", preferredStyle: .actionSheet)
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
                self.sendMail(postImageUserID: self.postImages[indexPath].userID!, postImageID: self.postImages[indexPath].idName!)
            }
            optionMenu.addAction(returns)
            let dismissPostImage = UIAlertAction(title: "隱藏貼文", style: .default) { (_) in
                self.dismissPostImage(postImageID: self.postImages[indexPath].idName!)
            }
            optionMenu.addAction(dismissPostImage)

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
            let successSentAction = UIAlertController(title: "回報送出", message: "已成功送出檢舉回報內容，將儘速審核。\n你將不會再看到此貼文。", preferredStyle: .alert)
            let click = UIAlertAction(title: "確認", style: .cancel) { (_) in
            }
            successSentAction.addAction(click)
            self.present(successSentAction, animated: true, completion: nil)
        }
    }

    // 隱藏貼文
    func dismissPostImage(postImageID: String) {
        if let userID = self.userID {
            self.dismissValue.append(postImageID)
            Database.database().reference().child("dismiss").updateChildValues([userID: self.dismissValue])
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
        let value = snapshot.value as? [String: Any],
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
