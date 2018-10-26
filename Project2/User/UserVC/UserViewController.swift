//
//  NewUserViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/31.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit
import Firebase

protocol SelectedCollectionItemDelegate: class {
    func selectedCollectionItem(index: Int)
}

class NewUserViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    weak var delegate: SelectedCollectionItemDelegate?

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userBackImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!

    @IBOutlet weak var oneCollectionView: UICollectionView!
    @IBOutlet weak var moreCellView: UIView!
    @IBOutlet weak var moreCollectionView: UICollectionView!

    @IBOutlet weak var oneCellButton: UIButton!
    @IBAction func oneCellButton(_ sender: UIButton) {
        Analytics.logEvent("user_one_cell_mode_button", parameters: nil)
        moreCellView.isHidden = true
        sender.isEnabled = false
        sender.tintColor = UIColor.blue
        self.moreCellButton.isEnabled = true
        self.moreCellButton.tintColor = UIColor.lightGray
    }
    @IBOutlet weak var moreCellButton: UIButton!
    @IBAction func moreCellButton(_ sender: UIButton) {
        Analytics.logEvent("user_more_cell_mode_button", parameters: nil)
        moreCellView.isHidden = false
        sender.isEnabled = false
        sender.tintColor = UIColor.blue
        self.oneCellButton.isEnabled = true
        self.oneCellButton.tintColor = UIColor.lightGray
    }

    @IBAction func settingUserImageButton(_ sender: AnyObject) {
        Analytics.logEvent("user_setting_user_image_button", parameters: nil)
        let actionSheet = UIAlertController(title: "上傳頭像", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)

        let updataAction = UIAlertAction(title: "相簿選取", style: .default) { (_) in
            Analytics.logEvent("user_use_photo_library_update_user_image", parameters: nil)
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
//            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }
        actionSheet.addAction(updataAction)

        let signOutAction = UIAlertAction(title: "登出", style: .destructive) { (_) in
            self.signOut()
        }
        actionSheet.addAction(signOutAction)

        let userPrivacvAction = UIAlertAction(title: "使用者隱私權條款", style: .default) { (_) in
            if let readUserPrivacyVC = self.storyboard?.instantiateViewController(withIdentifier: "readUserPrivacyVC") as? ReadUserPrivacyViewController {
                self.navigationController?.pushViewController(readUserPrivacyVC, animated: true)
            }
        }
        actionSheet.addAction(userPrivacvAction)

        // iPad
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        self.present(actionSheet, animated: true, completion: nil)
    }

    func signOut() {
        let actionController = UIAlertController(title: "你確定要登出嗎？", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消",
                                         style: .cancel,
                                         handler: nil)
        actionController.addAction(cancelAction)

        let signoutAction = UIAlertAction(title: "登出", style: .destructive) { _ in
            Analytics.logEvent("user_sign_out_alert_action", parameters: nil)

            do {
                try Auth.auth().signOut()
                LoadingUserPostImage.imageUrl.removeAll()
                self.dismiss(animated: true, completion: nil)
            }
            catch let error {
                print("Auth sign out failed: \(error)")
            }
        }
        actionController.addAction(signoutAction)
        self.present(actionController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        var selectedImageFromPicker: UIImage?
        // 取得從 UIImagePickerController 選擇到的檔案
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = pickedImage
        }
        // 關閉圖庫
        dismiss(animated: true, completion: nil)

        if let selectedImage = selectedImageFromPicker {
            if let userID = Auth.auth().currentUser?.uid {
                let userRef = Database.database().reference().child("users").child(userID)
                let storageRef = Storage.storage().reference().child("usersImage").child("\(userID).jpg")
                let uploadMetadata = StorageMetadata()
                uploadMetadata.contentType = "image/jpeg"
                if let uploadData = UIImageJPEGRepresentation(selectedImage, 0.2) {
                    storageRef.putData(uploadData, metadata: uploadMetadata) { (metadata, error) in
                        if let error = error {
                            print(error)
                            return
                        }
                        else {
                            print("\(String(describing: metadata))")
                        }

                        storageRef.downloadURL(completion: { (url, error) in
                            guard
                                let downloadURL = url else {
                                    print("\(String(describing: error))")
                                    return
                            }
                            print("userImageUrl: \(downloadURL)")
                            // database -> users/userID/ 建立 userImageUrl  data
                            userRef.updateChildValues(["userImageUrl": "\(downloadURL)"] as [AnyHashable: Any])
                        })
                    }
                }
            }
        }
    }

    func uploadUserImage() {
        guard
        let userID = Auth.auth().currentUser?.uid
            else {
                return
        }
        self.userImageView.image = UIImage(named: "iconUserImage")
        self.userImageView.tintColor = .gray
        self.userImageView.backgroundColor = .white
        Database.database().reference().child("users").child(userID).observe(.value) { (snapshot) in
            guard
            let value = snapshot.value as? [String: Any]
                else { return }
            if let userImageUrl = value["userImageUrl"] as? String {
                if let url = URL(string: userImageUrl) {
                    ImageService.getImage(withURL: url, completion: { (image) in
                        self.userImageView.image = image
                    })
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.tintColor = .black
        moreCellView.isHidden = false
        self.oneCellButton.isEnabled = true
        self.oneCellButton.tintColor = UIColor.lightGray
        self.moreCellButton.isEnabled = false
        self.moreCellButton.tintColor = UIColor.blue

        // get user image
        uploadUserImage()

        // get header user name
        LoadUserName.loadUserData(userNameLabel: self.userNameLabel)

        // xib
        oneCellXib()
        moreCellXib()
        // 抓貼文image
        LoadingUserPostImage.fethImage(oneCellCollectionView: oneCollectionView, moreCellCollectionView: moreCollectionView)
        print("viewDidLoad...")

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

    // collectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.oneCollectionView {
            print("NewLoadingImage.imageUrl.count -> \(LoadingUserPostImage.imageUrl.count)")
            return LoadingUserPostImage.imageUrl.count
        }
        else {
            return LoadingUserPostImage.imageUrl.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.oneCollectionView {
            guard let cellOne = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? NewHomeCollectionViewCell
                else {
                    fatalError()
            }
            cellOne.postImageView.image = nil
            let loadImage = LoadingUserPostImage.imageUrl[indexPath.row]
            if let url = URL(string: loadImage.postUrl!) {
                ImageService.getImage(withURL: url) { (image) in
                    cellOne.postImageView.image = image
                }
            }
            Database.database().reference().child("messages").child(LoadingUserPostImage.allPostImages[indexPath.row]).observe(.value) { (snapshot) in
                    var loadMessage = [String]()
                    var names = [String]()
                    loadMessage.removeAll()
                    for child in snapshot.children.allObjects {
                        if let snapshot = child as? DataSnapshot {
                            guard
                                let value = snapshot.value as? [String: Any],
                                let userID = value["userID"] as? String,
                                let message = value["message"] as? String
                            else {
                                loadMessage.removeAll()
                                names.removeAll()
                                collectionView.reloadData()
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
                                cellOne.messageLabel.attributedText = MessageSet.message(userName: names[0], messageText: loadMessage[0])

                            })
                        }
                    }
                }
            cellOne.userImageView.image = UIImage(named: "iconUserImage")
            cellOne.userImageView.tintColor = .gray
            cellOne.userImageView.backgroundColor = .white

            let userImageUrl = LoadingUserPostImage.loadUserImageUrl
            if let url = URL(string: userImageUrl) {
                ImageService.getImage(withURL: url, completion: { (image) in
                    cellOne.userImageView.image = image
                })
            }

            cellOne.userNameButton.setTitle(LoadingUserPostImage.userName, for: .normal)
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
            cellMore.postImageView.image = nil
            let loadImage = LoadingUserPostImage.imageUrl[indexPath.row]
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

extension NewUserViewController: CellDelegateProtocol {

    func userNameButton(indexPath: Int) {
        Analytics.logEvent("user_click_user_name_button", parameters: nil)
        if let otherUserVC = storyboard?.instantiateViewController(withIdentifier: "userVC") as? NewUserViewController {
            self.navigationController?.pushViewController(otherUserVC, animated: true)
        }
    }

    func otherFunctionPassData(indexPath: Int) {
        Analytics.logEvent("home_click_other_function_button", parameters: nil)
        if Auth.auth().currentUser?.uid == LoadingUserPostImage.imageUrl[indexPath].userID {
            let optionMenu = UIAlertController(title: "刪除", message: "你確定要刪除此貼文？\n刪除後將無法復原此貼文。", preferredStyle: .actionSheet)
            let cancleAction = UIAlertAction(title: "取消",
                                             style: .cancel,
                                             handler: nil)
            optionMenu.addAction(cancleAction)

            let deleteAction = UIAlertAction(title: "刪除", style: .destructive) { _ in
                //delete firebase data
                if let postImageID = LoadingUserPostImage.imageUrl[indexPath].idName {
                    //delete storage/images/(postImage.key)
                    DeletePost.deleteStorage(postImageID)
                    //delete postImage/(postImage.key)
                    DeletePost.deleteInPostImage(postImageID)
                    //delete messages/(postImage.key)
                    DeletePost.deleteInMessages(postImageID)
                    //delete users/(userID)/postImages["postImage.key"]
                    DeletePost.deleteInUser(postImageID)
                    let optionMenu = UIAlertController(title: "刪除成功", message: nil, preferredStyle: .alert)
                    let cancleAction = UIAlertAction(title: "ＯＫ", style: .default, handler: { (_) in
                        self.oneCollectionView.reloadData()
                        self.moreCollectionView.reloadData()
                    })
                    optionMenu.addAction(cancleAction)
                    self.present(optionMenu, animated: true, completion: nil)
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
    }

    func passData(indexPath: Int) {
        Analytics.logEvent("user_click_message_button", parameters: nil)
        if let messageVC = storyboard?.instantiateViewController(withIdentifier: "messageVC") as? MessageViewController,
            let imageID = LoadingUserPostImage.imageUrl[indexPath].idName ,
            let userID = LoadingUserPostImage.imageUrl[indexPath].userID {
            messageVC.commentInit(imageID, userID)
            self.navigationController?.pushViewController(messageVC, animated: true)
        }
    }
}
extension NewUserViewController: SelectedCollectionItemDelegate {
    func selectedCollectionItem(index: Int) {
        Analytics.logEvent("user_click_more_cell_open_post_image", parameters: nil)
        if let postImageVC = storyboard?.instantiateViewController(withIdentifier: "postImageVC") as? PostImageViewController,
            let postImageID = LoadingUserPostImage.imageUrl[index].idName,
            let userID = LoadingUserPostImage.imageUrl[index].userID {
            postImageVC.commendInit(postImageID: postImageID, userID: userID)
            self.navigationController?.pushViewController(postImageVC, animated: true)
        }
    }
}
