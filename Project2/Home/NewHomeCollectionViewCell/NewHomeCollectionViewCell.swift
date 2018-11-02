//
//  NewHomeCollectionViewCell.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/30.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit

protocol CellDelegateProtocol: class {
    func passData(indexPath: Int)

    func otherFunctionPassData(indexPath: Int)

    func userNameButton(indexPath: Int)
}

@IBDesignable
class NewHomeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameButton: UIButton!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var otherFunctionButton: UIButton!

    let backgroundGradientLayer = CAGradientLayer()
    @IBOutlet weak var widthConstrain: NSLayoutConstraint!
    @IBOutlet weak var messageLabel: UILabel!

    weak var deleggate: CellDelegateProtocol?
    var indexPath: IndexPath?

    @IBAction func messageButton(_ sender: Any) {
        deleggate?.passData(indexPath: (indexPath?.row)!)
    }
    @IBAction func otherFunctionButton(_ sender: UIButton) {
        deleggate?.otherFunctionPassData(indexPath: (indexPath?.row)!)
    }
    @IBAction func userNameButton(_ sender: UIButton) {
        deleggate?.userNameButton(indexPath: (indexPath?.row)!)
    }
//    func colorSet(view: UIView) {
//        backgroundGradientLayer.frame = view.bounds
//
//        let layer = backgroundGradientLayer
//        view.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
//        layer.colors = [
//                        UIColor(red: 0, green: 0, blue: 0, alpha: 0.0).cgColor,
//                        UIColor(red: 1, green: 1, blue: 1, alpha: 0.0).cgColor
//                    ]
//        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
//        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
//        view.layer.insertSublayer(layer, at: 0)
//    }
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        self.contentView.translatesAutoresizingMaskIntoConstraints = false
//        let screenWidth = UIScreen.main.bounds.size.width
//        widthConstrain.constant = screenWidth - (2 * 10)
//    }

}
