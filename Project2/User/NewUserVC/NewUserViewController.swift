//
//  NewUserViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/31.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit
import Firebase

protocol SelectedCollectionItemDelegate: class {
    func selectedCollectionItem(index: Int)
}

class NewUserViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    weak var delegate: SelectedCollectionItemDelegate?

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
        self.moreCellButton.isEnabled = true
    }
    @IBOutlet weak var moreCellButton: UIButton!
    @IBAction func moreCellButton(_ sender: UIButton) {
        moreCellView.isHidden = false
        sender.isEnabled = false
        self.oneCellButton.isEnabled = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.isNavigationBarHidden = true
        moreCellView.isHidden = false
        self.oneCellButton.isEnabled = true
        self.moreCellButton.isEnabled = false

        // get header user name
        LoadUserName.loadUserData(userNameLabel: self.userNameLabel)

        // xib
        oneCellXib()
        moreCellXib()

        // 抓貼文image
        NewLoadingImage.fethImage(collectionView: oneCollectionView)
        MoreLoadingImage.fethImage(collectionView: moreCollectionView)
    }

    // CollectionCell nib
    func oneCellXib() {
//        let nib = UINib(nibName: "OneUserCollectionViewCell", bundle: nil)
//        oneCollectionView.register(nib, forCellWithReuseIdentifier: "cell")
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

    // collectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.oneCollectionView {
            return NewLoadingImage.imageUrl.count
        }
        else {
            return MoreLoadingImage.imageUrl.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.oneCollectionView {
//            guard let cellOne = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? OneUserCollectionViewCell
            guard let cellOne = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? NewHomeCollectionViewCell
                else {
                    fatalError()
            }

            let loadImage = NewLoadingImage.imageUrl[indexPath.row]
            if let url = URL(string: loadImage.postUrl!) {
                ImageService.getImage(withURL: url) { (image) in
                    cellOne.postImageView.image = image
                }
            }
            cellOne.userImageView.backgroundColor = .green
            cellOne.userNameLabel.text = NewLoadingImage.userName
            cellOne.deleggate = self
            cellOne.indexPath = indexPath
            Database.database().reference().child("messages").child(NewLoadingImage.allPostImages[indexPath.row]).observe(.value) { (snapshot) in
                    var loadMessage = [String]()
                    loadMessage.removeAll()
                    for child in snapshot.children.allObjects {
                        if let snapshot = child as? DataSnapshot {
                            guard
                                let value = snapshot.value as? [String: AnyObject],
                                let message = value["message"] as? String,
                                let userID = value["userID"] as? String
                                else {
                                    return
                            }
                            loadMessage.append(message)
                            Database.database().reference().child("users").child(userID).observe(.value, with: { (snapshot) in
                                guard
                                    let value = snapshot.value as? [String: AnyObject],
                                    let name = value["userName"] as? String
                                    else {
                                        return
                                }
                                MessageSet.message(label: cellOne.messageLabel, userName: name, messageText: loadMessage[0])
                            })
                        }
                    }
                }

            cellOne.messageLabel.text = " "
            return cellOne
        }
        else {
            guard let cellMore = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? MoreUserCollectionViewCell
                else {
                    fatalError()
            }

            let loadImage = MoreLoadingImage.imageUrl[indexPath.row]
            if let url = URL(string: loadImage.postUrl!) {
                ImageService.getImage(withURL: url) { (image) in
                    cellMore.postImageView.image = image
                }
            }
            self.delegate = self
            return cellMore
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.moreCollectionView {
            let index = indexPath.row
            self.delegate?.selectedCollectionItem(index: index)
        }
    }
}
extension NewUserViewController: CellDelegateProtocol {
    func passData(indexPath: Int) {
        if let messageVC = storyboard?.instantiateViewController(withIdentifier: "messageVC") as? MessageViewController,
            let imageID = NewLoadingImage.loadImages[indexPath].idName {
            messageVC.commentInit(imageID)
            self.navigationController?.pushViewController(messageVC, animated: true)
        }
    }
}
extension NewUserViewController: SelectedCollectionItemDelegate {
    func selectedCollectionItem(index: Int) {
        if let postImageVC = storyboard?.instantiateViewController(withIdentifier: "postImageVC") as? PostImageViewController,
            let postImageID = MoreLoadingImage.imageUrl[index].idName {
            postImageVC.commendInit(postImageID: postImageID)
            self.navigationController?.pushViewController(postImageVC, animated: true)
        }
    }
}
