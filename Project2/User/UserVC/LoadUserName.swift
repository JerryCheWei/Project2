//
//  LoadUserName.swift
//  Project2
//
//  Created by chang-che-wei on 2018/9/2.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import Foundation
import Firebase

class LoadUserName {
   static func loadUserData(userNameLabel: UILabel) {
        guard let user = Auth.auth().currentUser
            else {
                return
        }
        let userRef = Database.database().reference(withPath: "users/\(user.uid)")
        userRef.observe(.value) { (snapshot) in
            guard
                let value = snapshot.value as? [String: Any],
                let userName = value["userName"] as? String
                else {
                    return
            }
            userNameLabel.text = userName
        }
    }

    static func loadOtherUserData(userNameLabel: UILabel, userID: String) {
        let userRef = Database.database().reference(withPath: "users/\(userID)")
        userRef.observe(.value) { (snapshot) in
            guard
                let value = snapshot.value as? [String: Any],
                let userName = value["userName"] as? String
                else {
                    return
            }
            userNameLabel.text = userName
        }
    }
}
