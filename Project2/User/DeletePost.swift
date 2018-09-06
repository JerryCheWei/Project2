//
//  DeletePost.swift
//  Project2
//
//  Created by chang-che-wei on 2018/9/5.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import Foundation
import Firebase

class DeletePost {
    static func deleteInPostImage(_ postImageID: String) {
        Database.database().reference().child("postImage").child("\(postImageID)").setValue(nil)
        print("delete postImage/\(postImageID)")
    }
    static func deleteInMessages(_ postImageID: String) {
        Database.database().reference().child("messages").child("\(postImageID)").setValue(nil)
        print("delete messages/\(postImageID)")
    }
    static func deleteInUser(_ postImageID: String) {
        if let userID = Auth.auth().currentUser?.uid {
            Database.database().reference(withPath: "users/\(userID)").observe(.value) { (snapshot) in
                guard let value = snapshot.value as? [String: AnyObject],
                    let postImages = value["postImages"] as? [String]
                    else { return }
            let deletePostImage = postImages.filter { $0 != "\(postImageID)"}
            Database.database().reference().child("users").child(userID).updateChildValues(["postImages": deletePostImage])
                print("delete users/(userID)/postImages[\(postImageID)]")
            }
        }
    }
    static func deleteStorage(_ postImageID: String) {
        let deleteRef = Storage.storage().reference().child("images/\(postImageID).jpg")
        deleteRef.delete { (error) in
            if let error = error {
                print(error)
            }
            else {
                print("firebase storage images/\(postImageID) is delete")
            }
        }
    }
}
