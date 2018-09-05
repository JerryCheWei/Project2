//
//  HomeViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/19.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

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
            self.postImages = loadPostImage
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

        if let url = URL(string: postImage.postUrl!) {
            ImageService.getImage(withURL: url) { (image) in
                cell.postImageView.image = image
            }
        }
        Database.database().reference().child("users").child(postImage.userID!).observe(.value) { (snapshot) in
            guard
                let value = snapshot.value as? [String: AnyObject],
                let name = value["userName"] as? String,
                let userImageUrl = value["userImageUrl"] as? String
                else {
                    return
            }
            cell.userNameLabel.text = name
            if let url = URL(string: userImageUrl) {
                ImageService.getImage(withURL: url) { (image) in
                    cell.userImageView.image = image
                }
            }
        }

        cell.userImageView.backgroundColor = .gray

        Database.database().reference().child("messages").child(postImage.idName!).observe(.value) { (snapshot) in
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
                            cell.messageLabel.attributedText = MessageSet.message(userName: name, messageText: loadMessage[0])
                        })
                    }
            }
        }

        // CellDelegate Protocol delegate
        cell.deleggate = self
        cell.indexPath = indexPath
        cell.colorSet(view: cell.colorView)
        cell.messageLabel.text = " "

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
}

extension HomeViewController: CellDelegateProtocol {
    func passData(indexPath: Int) {
       if  let messageVC = storyboard?.instantiateViewController(withIdentifier: "messageVC") as? MessageViewController,
        let imageID = postImages[indexPath].idName {
            messageVC.commentInit(imageID)
            self.navigationController?.pushViewController(messageVC, animated: true)
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
