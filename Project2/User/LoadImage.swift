//
//  loadImage.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/21.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import Foundation
import Firebase

class LoadingImage {

    static var imageUrl = [UserImages]()
    static var userName = String()
    static var loadImages = [UserImages]()

    static func fethImage(tableView: UITableView) {
        guard let userRef = Auth.auth().currentUser
            else { return }
        let userid = userRef.uid
        Database.database().reference(withPath: "users/\(userid)").observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [String: AnyObject],
                let postImages = value["postImages"] as? [String],
                let userName = value["userName"] as? String
                else { return }
            LoadingImage.userName = userName
            for postImage in postImages {
                Database.database().reference().child("postImage").child(postImage).observe(.value) { (snapshot) in

                        if let loadImageItem = UserImages.init(snapshot: snapshot) {
                            loadImages.append(loadImageItem)
                        }
                        LoadingImage.imageUrl = loadImages
                        print(LoadingImage.imageUrl)
                        tableView.reloadData()

                }
            }
        }
    }
}
class UserImages {
    let idName: String?
    let postUrl: String?

    init(idName: String, postUrl: String) {
        self.idName = idName
        self.postUrl = postUrl
    }

    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let idName = value["idName"] as? String,
            let postUrl = value["postUrl"] as? String
            else {
                return nil
        }
        self.idName = idName
        self.postUrl = postUrl
    }

}
