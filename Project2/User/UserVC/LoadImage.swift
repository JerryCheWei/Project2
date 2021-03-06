//
//  loadImage.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/21.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import Foundation
import Firebase

class UserImages {
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

// user self
class LoadingUserPostImage {

    static var imageUrl = [UserImages]()
    static var userName = String()
    static var allPostImages = [String]()
    static var loadUserImageUrl = String()

    static func fethImage(oneCellCollectionView: UICollectionView, moreCellCollectionView: UICollectionView) {

        guard let userID = Auth.auth().currentUser?.uid
            else {
                return
        }
        Database.database().reference(withPath: "users/\(userID)").observe(.value) { (snapshot) in
            guard
                let value = snapshot.value as? [String: Any],
                let userName = value["userName"] as? String
            else { return }
            LoadingUserPostImage.userName = userName

            if let userImageUrl = value["userImageUrl"] as? String {
                loadUserImageUrl = userImageUrl
            }

            guard
                let postImages = value["postImages"] as? [String]
            else {
                print("NewLoadingImage no postImages")
                imageUrl.removeAll()
                oneCellCollectionView.reloadData()
                moreCellCollectionView.reloadData()
                return
            }

            allPostImages = postImages.reversed()
            imageUrl.removeAll()
            print("NewLoadingImage removeAll")
            var images = [UserImages]()

            for postImage in postImages {
                Database.database().reference().child("postImage").child(postImage).observe(.value) { (snapshot) in

                    if let loadImageItem = UserImages.init(snapshot: snapshot) {
                        images.append(loadImageItem)
                    }
                    LoadingUserPostImage.imageUrl = images.reversed()
                    oneCellCollectionView.reloadData()
                    moreCellCollectionView.reloadData()
                    print("NewLoadingImage class \n-> imageUrl \(imageUrl) \n-> allPostImages \(allPostImages)\n")
                }
            }
        }
    }
}

// other user
class LoadingOtherUserPostImage {

    static var imageUrl = [UserImages]()
    static var userName = String()
    static var allPostImages = [String]()
    static var loadUserImageUrl = String()

    static func fethImage(oneCellCollectionView: UICollectionView, moreCellCollectionView: UICollectionView, userID: String) {

        Database.database().reference(withPath: "users/\(userID)").observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [String: Any],
                let userName = value["userName"] as? String
                else { return }
            LoadingOtherUserPostImage.userName = userName

            if let userImageUrl = value["userImageUrl"] as? String {
                loadUserImageUrl = userImageUrl
            }

            guard let postImages = value["postImages"] as? [String]
                else {
                    print("NewLoadingImage no postImages")
                    imageUrl.removeAll()
                    oneCellCollectionView.reloadData()
                    moreCellCollectionView.reloadData()
                    return
            }

            imageUrl.removeAll()
            print("NewLoadingImage removeAll")

            allPostImages = postImages.reversed()
            var images = [UserImages]()
            for postImage in postImages {
                Database.database().reference().child("postImage").child(postImage).observe(.value) { (snapshot) in

                    if let loadImageItem = UserImages.init(snapshot: snapshot) {
                        images.append(loadImageItem)
                    }
                    LoadingOtherUserPostImage.imageUrl = images.reversed()
                    oneCellCollectionView.reloadData()
                    moreCellCollectionView.reloadData()
                }
            }
        }
    }
}
