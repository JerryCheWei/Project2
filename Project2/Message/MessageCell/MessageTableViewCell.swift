//
//  MessageTableViewCell.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/24.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    //@IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userMessageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
