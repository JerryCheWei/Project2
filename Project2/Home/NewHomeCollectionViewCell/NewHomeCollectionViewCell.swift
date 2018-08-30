//
//  NewHomeCollectionViewCell.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/30.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit

protocol CellDelegateProtocol {
    func passData(indexPath: Int)
}

@IBDesignable
class NewHomeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var colorView: UIView!
    let backgroundGradientLayer = CAGradientLayer()

    var deleggate: CellDelegateProtocol?
    var indexPath: IndexPath?

    @IBAction func messageButton(_ sender: Any) {
        deleggate?.passData(indexPath: (indexPath?.row)!)
    }

    func colorSet(view: UIView) {
        backgroundGradientLayer.frame = view.bounds

        let layer = backgroundGradientLayer
        view.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        layer.colors = [
                        UIColor(red: 0, green: 0, blue: 0, alpha: 0.0).cgColor,
                        UIColor(red: 1, green: 1, blue: 1, alpha: 0.0).cgColor
                    ]
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        view.layer.insertSublayer(layer, at: 0)
    }

}