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

    var postImage = [String]()

    func fetchImage() {

        Database.database().reference().child("postImage").observe(.childAdded) { (snapshot) in
            let post = snapshot.value as? String
            if let loadPost = post {
                self.postImage.append(loadPost)
                self.collectionView.reloadData()
            }
        }

    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postImage.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? HomeCollectionViewCell
            else { fatalError() }
        let postImage = self.postImage[indexPath.row]

        let url = URL(string: postImage)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }

            DispatchQueue.main.async {
                cell.loadAllImageView.image = UIImage(data: data!)
            }

            }.resume()
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchImage()
    }
}