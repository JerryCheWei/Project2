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
    var userID: String?

    func commendInit(postImageID: String, userID: String) {
        self.postImageID = String()
        self.postImageID = postImageID
        self.userID = userID
    }
    @IBAction func messageButton(_ sender: UIButton) {
        if let messageVC = storyboard?.instantiateViewController(withIdentifier: "messageVC") as? MessageViewController,
            let imageID = self.postImageID {
            messageVC.commentInit(imageID)
            self.navigationController?.pushViewController(messageVC, animated: true)
        }
    }
    @IBAction func otherFunctionButton(_ sender: UIButton) {
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
            self.present(optionMenu, animated: true, completion: nil)
        }
        else {
            let optionMenu = UIAlertController(title: "未來可擴增功能", message: nil, preferredStyle: .actionSheet)
            let cancleAction = UIAlertAction(title: "取消",
                                             style: .cancel,
                                             handler: nil)
            optionMenu.addAction(cancleAction)
            self.present(optionMenu, animated: true, completion: nil)
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
