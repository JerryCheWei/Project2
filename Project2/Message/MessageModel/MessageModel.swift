//
//  MessageModel.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/24.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class MessageSet {

    // set message font
    static func message(label: UILabel, userName: String, messageText: String) {
        let attrs1 = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.bold), NSAttributedStringKey.foregroundColor: UIColor.black]

        let attrs2 = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15), NSAttributedStringKey.foregroundColor: UIColor.black]

        let attributedString1 = NSMutableAttributedString(string: "\(userName)  ", attributes: attrs1)

        let attributedString2 = NSMutableAttributedString(string: "\(messageText)", attributes: attrs2)

        attributedString1.append(attributedString2)
        label.attributedText = attributedString1
    }
}

class LoadMessage {
    let userID: String?
    let message: String?

    init(userID: String, message: String) {
        self.userID = userID
        self.message = message
    }

    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let userID = value["idName"] as? String,
            let message = value["message"] as? String
            else {
                return nil
        }

        self.userID = userID
        self.message = message
    }

}

class MessageModel {
    static var allMessage = [LoadMessage]()

    static func fetchMessage(messageTableView: UITableView) {
        guard
            let postImageID = UserDefaults.standard.string(forKey: "postImageID")
            else {
                return
        }

        Database.database().reference().child("messages").child(postImageID).observe(.value) { (snapshot) in
            var loadMessage = [LoadMessage]()
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let loadMessageItem = LoadMessage.init(snapshot: snapshot) {
                    loadMessage.append(loadMessageItem)
                }
            }
            MessageModel.allMessage = loadMessage
            messageTableView.reloadData()
        }

    }
}
