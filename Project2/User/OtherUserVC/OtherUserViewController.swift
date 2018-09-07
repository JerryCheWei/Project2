//
//  OtherUserViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/9/6.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit
import Firebase

class OtherUserViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    weak var delegate: SelectedCollectionItemDelegate?

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userBackImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!

    @IBOutlet weak var oneCollectionView: UICollectionView!
    @IBOutlet weak var moreCellView: UIView!
    @IBOutlet weak var moreCollectionView: UICollectionView!

    @IBOutlet weak var oneCellButton: UIButton!
    @IBAction func oneCellButton(_ sender: UIButton) {
        Analytics.logEvent("otherUserVc_OneCellModeButton", parameters: nil)
        moreCellView.isHidden = true
        sender.isEnabled = false
        sender.tintColor = UIColor.blue
        self.moreCellButton.isEnabled = true
        self.moreCellButton.tintColor = UIColor.lightGray
    }
    @IBOutlet weak var moreCellButton: UIButton!
    @IBAction func moreCellButton(_ sender: UIButton) {
        Analytics.logEvent("otherUserVc_MoreCellModeButton", parameters: nil)
        moreCellView.isHidden = false
        sender.isEnabled = false
        sender.tintColor = UIColor.blue
        self.oneCellButton.isEnabled = true
        self.oneCellButton.tintColor = UIColor.lightGray
    }

    var userID: String = ""
    func commentInit(_ userID: String) {
        self.userID = userID
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.isNavigationBarHidden = false
        moreCellView.isHidden = false
        self.oneCellButton.isEnabled = true
        self.oneCellButton.tintColor = UIColor.lightGray
        self.moreCellButton.isEnabled = false
        self.moreCellButton.tintColor = UIColor.blue
        // xib
        oneCellXib()
        moreCellXib()
        // get header user image
        uploadUserImage(self.userID)
        // get header user name
        LoadUserName.loadOtherUserData(userNameLabel: self.userNameLabel, userID: self.userID)
        // 抓貼文image
        OtherUserLoadingImage.fethImage(collectionView: oneCollectionView, userID: self.userID)
        OtherUserMoreLoadingImage.fethImage(collectionView: moreCollectionView, userID: self.userID)
    }

    // CollectionCell nib
    func oneCellXib() {
        let nib = UINib.init(nibName: "NewHomeCollectionViewCell", bundle: nil)
        oneCollectionView.register(nib, forCellWithReuseIdentifier: "cell")
        if let flowLayout = oneCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
    }
    func moreCellXib() {
        let nib = UINib(nibName: "MoreUserCollectionViewCell", bundle: nil)
        moreCollectionView.register(nib, forCellWithReuseIdentifier: "cell")
    }

    func uploadUserImage(_ userID: String) {
        Database.database().reference().child("users").child(userID).observe(.value) { (snapshot) in
            guard
                let value = snapshot.value as? [String: AnyObject],
                let userImageUrl = value["userImageUrl"] as? String
                else {
                    return
            }
            if let url = URL(string: userImageUrl) {
                ImageService.getImage(withURL: url, completion: { (image) in
                    self.userImageView.image = image
                })
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.oneCollectionView {
            print("OtherUserLoadingImage.imageUrl.count: \(OtherUserLoadingImage.imageUrl.count)")
            return OtherUserLoadingImage.imageUrl.count
        }
        else {
            print("OtherUserMoreLoadingImage.imageUrl.count: \(OtherUserMoreLoadingImage.imageUrl.count)")
            return OtherUserMoreLoadingImage.imageUrl.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.oneCollectionView {
            guard let cellOne = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? NewHomeCollectionViewCell
                else {
                    fatalError()
            }

            let loadImage = OtherUserLoadingImage.imageUrl[indexPath.row]
            if let url = URL(string: loadImage.postUrl!) {
                ImageService.getImage(withURL: url) { (image) in
                    cellOne.postImageView.image = image
                }
            }

            Database.database().reference().child("messages").child(OtherUserLoadingImage.allPostImages[indexPath.row]).observe(.value) { (snapshot) in
                var loadMessage = [String]()
                loadMessage.removeAll()
                for child in snapshot.children.allObjects {
                    if let snapshot = child as? DataSnapshot {
                        guard
                            let value = snapshot.value as? [String: AnyObject],
                            let message = value["message"] as? String,
                            let userID = value["userID"] as? String
                            else {
                                return
                        }
                        loadMessage.append(message)
                        Database.database().reference().child("users").child(userID).observe(.value, with: { (snapshot) in
                            guard
                                let value = snapshot.value as? [String: AnyObject],
                                let name = value["userName"] as? String
                                else {
                                    return
                            }
                            cellOne.messageLabel.attributedText = MessageSet.message(userName: name, messageText: loadMessage[0])
                        })
                    }
                }
            }

            let userImageUrl = OtherUserLoadingImage.loadUserImageUrl
            if let url = URL(string: userImageUrl) {
                ImageService.getImage(withURL: url, completion: { (image) in
                    cellOne.userImageView.image = image
                })
            }

            cellOne.userImageView.backgroundColor = .green
            cellOne.userNameButton.setTitle(OtherUserLoadingImage.userName, for: .normal)
            cellOne.deleggate = self
            cellOne.indexPath = indexPath
            cellOne.messageLabel.text = " "

            return cellOne
        }
        else {
            guard let cellMore = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? MoreUserCollectionViewCell
                else {
                    fatalError()
                }

            let loadImage = OtherUserMoreLoadingImage.imageUrl[indexPath.row]
            if let url = URL(string: loadImage.postUrl!) {
                ImageService.getImage(withURL: url) { (image) in
                    cellMore.postImageView.image = image
                }
            }
            self.delegate = self

            return cellMore
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.moreCollectionView {
            let index = indexPath.row
            self.delegate?.selectedCollectionItem(index: index)
        }
    }
}

extension OtherUserViewController: SelectedCollectionItemDelegate {
    func selectedCollectionItem(index: Int) {
        Analytics.logEvent("otherUserVc_ClickMoreCellOpenPostImageVc", parameters: nil)
        if let postImageVC = storyboard?.instantiateViewController(withIdentifier: "postImageVC") as? PostImageViewController,
            let postImageID = OtherUserMoreLoadingImage.imageUrl[index].idName,
            let userID = OtherUserMoreLoadingImage.imageUrl[index].userID {
            postImageVC.commendInit(postImageID: postImageID, userID: userID)
            self.navigationController?.pushViewController(postImageVC, animated: true)
        }
    }
}

extension OtherUserViewController: CellDelegateProtocol {
    func passData(indexPath: Int) {
        Analytics.logEvent("otherUserVc_ClickMessageButton", parameters: nil)
        if let messageVC = storyboard?.instantiateViewController(withIdentifier: "messageVC") as? MessageViewController,
            let imageID = OtherUserLoadingImage.loadImages[indexPath].idName {
            messageVC.commentInit(imageID)
            self.navigationController?.pushViewController(messageVC, animated: true)
        }
    }

    func otherFunctionPassData(indexPath: Int) {
        Analytics.logEvent("otherUserVc_ClickOtherFunctionButton", parameters: nil)
        if Auth.auth().currentUser?.uid != OtherUserMoreLoadingImage.loadImages[indexPath].userID {
            let optionMenu = UIAlertController(title: "未來擴增功能", message: nil, preferredStyle: .actionSheet)
            let cancleAction = UIAlertAction(title: "取消",
                                             style: .cancel,
                                             handler: nil)
            optionMenu.addAction(cancleAction)
            self.present(optionMenu, animated: true, completion: nil)
        }
    }

    func userNameButton(indexPath: Int) {
        if Auth.auth().currentUser?.uid == OtherUserLoadingImage.imageUrl[indexPath].userID {
            Analytics.logEvent("otherUserVc_ClickSelfUserNameButton", parameters: nil)
            if let userVC = storyboard?.instantiateViewController(withIdentifier: "userVC") as? NewUserViewController {
                self.navigationController?.pushViewController(userVC, animated: true)
            }
        }
        else {
            Analytics.logEvent("otherUserVc_ClickUserNameButton", parameters: nil)
            if let otherUserVC = storyboard?.instantiateViewController(withIdentifier: "otherUserVC") as? OtherUserViewController,
                let userID = OtherUserLoadingImage.imageUrl[indexPath].userID {
                otherUserVC.commentInit(userID)
                self.navigationController?.pushViewController(otherUserVC, animated: true)
            }
        }
    }
}
