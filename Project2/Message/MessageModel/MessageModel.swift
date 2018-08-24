//
//  MessageModel.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/24.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import Foundation
import UIKit

class MessageSet {

    // set message font
    static func message(label: UILabel, userName: String, messageText: String) {
        let attrs1 = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.bold), NSAttributedStringKey.foregroundColor: UIColor.black]

        let attrs2 = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15), NSAttributedStringKey.foregroundColor: UIColor.black]

        let attributedString1 = NSMutableAttributedString(string: "\(userName)  ", attributes: attrs1)

        let attributedString2 = NSMutableAttributedString(string: "\(messageText)", attributes: attrs2)

        attributedString1.append(attributedString2)
        label.attributedText = attributedString1
    }
}
