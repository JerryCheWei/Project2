//
//  NewUserViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/31.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit

class NewUserViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var oneCollectionView: UICollectionView!

    @IBOutlet weak var moreCellView: UIView!
    @IBOutlet weak var moerCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true
        oneCellXib()
        // 抓貼文image
        NewLoadingImage.fethImage(collectionView: oneCollectionView)
        moreCellView.isHidden = true
    }

    // oneCollectionCell
    func oneCellXib() {
        let nib = UINib(nibName: "OneUserCollectionViewCell", bundle: nil)
        oneCollectionView.register(nib, forCellWithReuseIdentifier: "cell")
    }

    // collectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(NewLoadingImage.imageUrl.count)
        return NewLoadingImage.imageUrl.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
