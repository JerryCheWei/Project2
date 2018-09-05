//
//  PostImageViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/9/2.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit
import Firebase

class PostImageViewController: UIViewController {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var otherFunctionButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    var postImageID: String?

    func commendInit(postImageID: String) {
        self.postImageID = String()
        self.postImageID = postImageID
    }
    @IBAction func messageButton(_ sender: UIButton) {
        if let messageVC = storyboard?.instantiateViewController(withIdentifier: "messageVC") as? MessageViewController,
            let imageID = self.postImageID {
            messageVC.commentInit(imageID)
            self.navigationController?.pushViewController(messageVC, animated: true)
        }
    }
    @IBAction func otherFunctionButton(_ sender: UIButton) {
        let optionMenu = UIAlertController(title: "刪除", message: "你確定要刪除此貼文？", preferredStyle: .actionSheet)
        let cancleAction = UIAlertAction(title: "取消",
                                         style: .cancel,
                                         handler: nil)
        optionMenu.addAction(cancleAction)

        // 刪除貼文功能(未完)
        let deleteAction = UIAlertAction(title: "刪除", style: .destructive) { _ in
            //delete firebase data
            if let postImageID = self.postImageID {
                //delete storage/images/(postImage.key)
                self.deleteStorage(postImageID)
                //delete postImage/(postImage.key)
                self.deleteInPostImage(postImageID)
                //delete messages/(postImage.key)
                self.deleteInMessages(postImageID)
                //delete users/(userID)/postImages["postImage.key"]
                self.deleteInUser(postImageID)
            }
        }
        optionMenu.addAction(deleteAction)

        self.present(optionMenu, animated: true, completion: nil)
    }
    func deleteInPostImage(_ postImageID: String) {
        Database.database().reference().child("postImage").child("\(postImageID)").setValue(nil)
        print("delete postImage/\(postImageID)")
    }
    func deleteInMessages(_ postImageID: String) {
        Database.database().reference().child("messages").child("\(postImageID)").setValue(nil)
        print("delete messages/\(postImageID)")
    }
    func deleteInUser(_ postImageID: String) {
        if let userID = Auth.auth().currentUser?.uid {
           let deletePostImage = MoreLoadingImage.userPostImages.filter { $0 != "\(postImageID)"}
            Database.database().reference().child("users").child(userID).updateChildValues(["postImages": deletePostImage])
            print("delete users/(userID)/postImages[\(postImageID)]")
        }
    }
    func deleteStorage(_ postImageID: String) {
        let deleteRef = Storage.storage().reference().child("images/\(postImageID).jpg")
            deleteRef.delete { (error) in
            if let error = error {
                print(error)
            }
            else {
                print("firebase storage images/\(postImageID) is delete")
                self.navigationController?.popViewController(animated: true)
            }
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
                guard let value = snapshot.value as? [String: AnyObject],
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
                Database.database().reference().child("users").child(userID).observe(.value, with: { (snapshot) in
                    guard let value = snapshot.value as? [String: AnyObject],
                        let name = value["userName"] as? String,
                        let userImageUrl = value["userImageUrl"] as? String
                        else {
                            return
                    }
                    self.userNameLabel.text = name
                    if let url = URL(string: userImageUrl) {
                        ImageService.getImage(withURL: url) { (image) in
                            self.userImageView.image = image
                        }
                    }
                })
            }
        }
    }

}
