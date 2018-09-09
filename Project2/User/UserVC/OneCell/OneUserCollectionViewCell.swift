//
//  OneUserCollectionViewCell.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/31.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit

protocol OneCellDelegateProtocol {
    func passData(indexPath: Int)
}

@IBDesignable
class OneUserCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var colorView: UIView!

    var deleggate: OneCellDelegateProtocol?
    var indexPath: IndexPath?

    @IBAction func messageButton(_ sender: Any) {
        deleggate?.passData(indexPath: (indexPath?.row)!)
    }
}
