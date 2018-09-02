//
//  NewUserViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/31.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit

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
        let nib = UINib(nibName: "OneUserCollectionViewCell", bundle: nil)
        oneCollectionView.register(nib, forCellWithReuseIdentifier: "cell")
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
            guard let cellOne = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? OneUserCollectionViewCell
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
extension NewUserViewController: OneCellDelegateProtocol {
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
