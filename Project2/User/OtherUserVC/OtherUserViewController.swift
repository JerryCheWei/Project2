//
//  OtherUserViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/9/6.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit
import Firebase

class OtherUserViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userBackImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!

    @IBOutlet weak var oneCollectionView: UICollectionView!
    @IBOutlet weak var moreCellView: UIView!
    @IBOutlet weak var moreCollectionView: UICollectionView!

    @IBOutlet weak var oneCellButton: UIButton!
    @IBAction func oneCellButton(_ sender: UIButton) {
        moreCellView.isHidden = true
        sender.isEnabled = false
        sender.tintColor = UIColor.blue
        self.moreCellButton.isEnabled = true
        self.moreCellButton.tintColor = UIColor.lightGray
    }
    @IBOutlet weak var moreCellButton: UIButton!
    @IBAction func moreCellButton(_ sender: UIButton) {
        moreCellView.isHidden = false
        sender.isEnabled = false
        sender.tintColor = UIColor.blue
        self.oneCellButton.isEnabled = true
        self.oneCellButton.tintColor = UIColor.lightGray
    }

    var userID: String = ""
    func commentInit(_ userID: String) {
        self.userID = userID
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.isNavigationBarHidden = false
        moreCellView.isHidden = false
        self.oneCellButton.isEnabled = true
        self.oneCellButton.tintColor = UIColor.lightGray
        self.moreCellButton.isEnabled = false
        self.moreCellButton.tintColor = UIColor.blue
        oneCellXib()
        moreCellXib()
        uploadUserImage(self.userID)
        LoadUserName.loadOtherUserData(userNameLabel: self.userNameLabel, userID: self.userID)
    }

    // CollectionCell nib
    func oneCellXib() {
        let nib = UINib.init(nibName: "NewHomeCollectionViewCell", bundle: nil)
        oneCollectionView.register(nib, forCellWithReuseIdentifier: "cell")
        if let flowLayout = oneCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
    }
    func moreCellXib() {
        let nib = UINib(nibName: "MoreUserCollectionViewCell", bundle: nil)
        moreCollectionView.register(nib, forCellWithReuseIdentifier: "cell")
    }

    func uploadUserImage(_ userID: String) {
        Database.database().reference().child("users").child(userID).observe(.value) { (snapshot) in
            guard
                let value = snapshot.value as? [String: AnyObject],
                let userImageUrl = value["userImageUrl"] as? String
                else {
                    return
            }
            if let url = URL(string: userImageUrl) {
                ImageService.getImage(withURL: url, completion: { (image) in
                    self.userImageView.image = image
                })
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.oneCollectionView {
            return 1
        }
        else {
            return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.oneCollectionView {
            guard let cellOne = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? NewHomeCollectionViewCell
                else {
                    fatalError()
            }

            return cellOne
        }
        else {
            guard let cellMore = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? MoreUserCollectionViewCell
                else {
                    fatalError()
                }

            return cellMore
        }
    }

}
