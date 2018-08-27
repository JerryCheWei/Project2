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

    @IBOutlet weak var collectionView: UICollectionView!

    @IBAction func signoutButton(_ sender: Any) {
        do {
            try Auth.auth().signOut()

            self.dismiss(animated: true, completion: nil)
        }
        catch let error {
            print("Auth sign out failed: \(error)")
        }
    }

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
            print(loadPostImage)
            self.postImages = loadPostImage
            self.collectionView.reloadData()
        }

    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? HomeCollectionViewCell
            else { fatalError() }
        let postImage = self.postImages[indexPath.row]

        if let url = URL(string: postImage.postUrl!) {
            ImageService.getImage(withURL: url) { (image) in
                cell.loadAllImageView.image = image
            }
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let postImageItem = postImages[indexPath.row]
        let postImageID = postImageItem.idName
        UserDefaults.standard.set(postImageID, forKey: "postImageID")
        UserDefaults.standard.synchronize()
        print(postImageID!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchImage()
    }
}

class PostImage {
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
