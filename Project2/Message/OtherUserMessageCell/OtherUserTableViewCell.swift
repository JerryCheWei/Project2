//
//  OtherUserTableViewCell.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/24.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit

class OtherUserTableViewCell: UITableViewCell {

    @IBOutlet weak var otherUserImageView: UIImageView!
    @IBOutlet weak var otherUserNameLabel: UILabel!
    @IBOutlet weak var otherUserMessageLabel: UILabel!
    var userName = "Jerry"
    var messageText = "hihihhihiiih"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        message()
    }

    func message() {
        let attrs1 = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.bold), NSAttributedStringKey.foregroundColor: UIColor.black]

        let attrs2 = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15), NSAttributedStringKey.foregroundColor: UIColor.black]

        let attributedString1 = NSMutableAttributedString(string: "\(userName)  ", attributes: attrs1)

        let attributedString2 = NSMutableAttributedString(string: "\(messageText)", attributes: attrs2)

        attributedString1.append(attributedString2)
        self.otherUserMessageLabel.attributedText = attributedString1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
