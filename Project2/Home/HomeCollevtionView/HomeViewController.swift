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

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MFMailComposeViewControllerDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var liveCollectionView: UICollectionView!
    @IBOutlet weak var homeCollectionView: UICollectionView!

    @IBAction func goLiveVCButton(_ sender: UIButton) {
        guard let liveVC = storyboard?.instantiateViewController(withIdentifier: "YTStreaming") else {
            return
        }
        present(liveVC, animated: true, completion: nil)
    }

    let userID = Auth.auth().currentUser?.uid
    var postImages = [PostImage]()
    var dismissValue = [String]()
    var liveStream = [LiveStream]()

    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchImage()
        fetchLiveStream()

        // set all collcetion cell xib
        self.setXib()

        let accessToken = UserDefaults.standard.string(forKey: "accessToken")
        GoogleOAuth2.sharedInstance.accessToken = accessToken
        print("accessToken: \(accessToken ?? "no get token")")

        refreshControl = UIRefreshControl()
        homeCollectionView.addSubview(refreshControl)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.liveCollectionView.reloadData()
    }

    func setXib() {
        // homeCell
        let nib = UINib.init(nibName: "NewHomeCollectionViewCell", bundle: nil)
        homeCollectionView.register(nib, forCellWithReuseIdentifier: "cell")
        // liveCell
        let liveNib = UINib.init(nibName: "LiveCellCollectionViewCell", bundle: nil)
        liveCollectionView.register(liveNib, forCellWithReuseIdentifier: "liveCell")
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl.isRefreshing {
            fetchImage()
            fetchLiveStream()
        }
    }

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

    func fetchLiveStream() {
        self.liveStream.removeAll()
        Database.database().reference().child("liveStreams").observe(.value) { (snapshot) in
            self.liveStream.removeAll()
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let liveStreamItem = LiveStream.init(snapshot: snapshot) {
                    self.liveStream.append(liveStreamItem)
                    self.liveCollectionView.reloadData()
                }
            }
            self.refreshControl.endRefreshing()
        }
        self.liveCollectionView.reloadData()
    }

    // MARK: collectionDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == liveCollectionView {
            return self.liveStream.count
        }
        else {
            print("postImages.count ~~~~~~~~~~~ \(postImages.count)")
            return postImages.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == liveCollectionView {

            guard let livecell = collectionView.dequeueReusableCell(withReuseIdentifier: "liveCell", for: indexPath) as? LiveCellCollectionViewCell
                else {
                    fatalError()
            }

            livecell.liveUserImageView.backgroundColor = .gray
            livecell.liveUserImageView.layer.cornerRadius = 20

            livecell.circleView.layer.cornerRadius = 25
            livecell.circleView.layer.borderWidth = 3
            livecell.circleView.layer.borderColor = UIColor.red.cgColor
            livecell.circleView.alpha = 1

            UIView.animate(withDuration: 0.7, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
                livecell.circleView.alpha = 0.2
            }, completion: nil)

            if let userId = self.liveStream[indexPath.row].userID {
                Database.database().reference().child("users").child(userId).observe(.value) { (snapshot) in
                    guard
                        let value = snapshot.value as? [String: Any]
                        else {
                            return
                    }

                    if let userImageUrl = value["userImageUrl"] as? String {
                        if let url = URL(string: userImageUrl) {
                            ImageService.getImage(withURL: url) { (image) in
                                livecell.liveUserImageView.image = image
                            }
                        }
                    }
                }
            }

            return livecell
        }
        else {
            return homeCellSet(collectionView, indexPath: indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == liveCollectionView {
            print(indexPath.row)
            if let liveBroadcastID = liveStream[indexPath.row].liveBroadcastID {
                YouTubePlayer.playYoutubeID(liveBroadcastID, viewController: self)
            }
        }
    }

    func homeCellSet(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == homeCollectionView {
            return CGSize(width: self.homeCollectionView.frame.width-20, height: 522)
        }
        else {
            return CGSize(width: 50, height: 50)
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

//"liveStream": streamUrl
//"userID": user.uid
class LiveStream {
    let liveBroadcastID: String?
    let userID: String?

    init(liveBroadcastID: String, userID: String) {
        self.liveBroadcastID = liveBroadcastID
        self.userID = userID
    }

    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: Any],
            let liveBroadcastID = value["liveBroadcastID"] as? String,
            let userID = value["userID"] as? String
            else {
                return nil
        }

        self.liveBroadcastID = liveBroadcastID
        self.userID = userID
    }
}
