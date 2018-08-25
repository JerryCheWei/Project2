//
//  MessageTableViewCell.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/24.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    //@IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userMessage: UILabel!
    var userName = "Jerry"
    var messageText = "joidjpv voasidjvpo advj aosidj apo djv aosid jvasvwoei jov w weofi jw o."

    override func awakeFromNib() {
        super.awakeFromNib()
        // Message Model
        MessageSet.message(label: userMessage, userName: userName, messageText: messageText)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
