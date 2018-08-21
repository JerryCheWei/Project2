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

    static func fethImage(tableView: UITableView) {
        Database.database().reference().child("postImage").observe(DataEventType.childAdded) { (snapshot) in
            let imageUrls = snapshot.value as? String
            if let loadImage = imageUrls {
                LoadingImage.imageUrl.append(loadImage)
                tableView.reloadData()
            }
        }
    }

    

}
