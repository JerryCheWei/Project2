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

    static var imageUrl = [String]()
    static var userName = String()

    static func fethImage(tableView: UITableView) {
        guard let userRef = Auth.auth().currentUser
            else { return }
        let userid = userRef.uid
        Database.database().reference(withPath: "users/\(userid)").observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [String: AnyObject],
                let postImages = value["postImages"] as? [String],
                let userName = value["userName"] as? String
                else { return }
            print(postImages)
            LoadingImage.userName = userName
            LoadingImage.imageUrl.removeAll()
            for postImage in postImages {
                print(postImage)
                Database.database().reference().child("postImage").observe(.value) { (snapshot) in
                    guard let value = snapshot.value as? [String: AnyObject],
                        let imageUrl = value[postImage] as? String
                        else { return }

                        LoadingImage.imageUrl.append(imageUrl)
                        tableView.reloadData()
                    print(LoadingImage.imageUrl.count)
                }
            }
        }
    }
}
