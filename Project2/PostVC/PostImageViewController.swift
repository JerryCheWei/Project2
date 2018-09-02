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
        self.postImageID = postImageID
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.isNavigationBarHidden = false

        fetchImage()
    }

    func fetchImage() {
        if let postImageID = self.postImageID {
            print(postImageID)
            Database.database().reference().child("postImage").child(postImageID).observe(.value) { (snapshot) in
                guard let value = snapshot.value as? [String: AnyObject],
                    let userID = value["userID"] as? String,
                    let postImage = value["postUrl"] as? String
                    else {
                        fatalError()
                }
                if let url = URL(string: postImage) {
                    ImageService.getImage(withURL: url, completion: { (image) in
                        self.postImageView.image = image
                    })
                }
                Database.database().reference().child("users").child(userID).observe(.value, with: { (snapshot) in
                    guard let value = snapshot.value as? [String: AnyObject],
                        let name = value["userName"] as? String
                        else {
                            fatalError()
                    }
                    self.userNameLabel.text = name
                })
            }
        }
    }

}
