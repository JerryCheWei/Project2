//
//  HeaderViewSet.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/21.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import Foundation
import UIKit

class HeaderViewSet {

   static func decrementColorAlpha(offset: CGFloat, view: UIView) {
        if view.alpha <= 1 {
            let alphaOffset = (offset/500)/85
            view.alpha += alphaOffset
        }
    }
   static func decrementArticleAlpha(offset: CGFloat, label: UILabel) {
        if label.alpha >= 0 {
            let alphaOffset = max((offset - 65)/85.0, 0)
            label.alpha = alphaOffset
        }
    }
   static func incrementColorAlpha(offset: CGFloat, view: UIView) {
        if view.alpha >= 0.3 {
            let alphaOffset = (offset/100)/85
            view.alpha -= alphaOffset
        }
    }
   static func incrementArticleAlpha(offset: CGFloat, label: UILabel) {
        if label.alpha <= 1 {
            let alphaOffset = max((offset - 65)/85, 0)
            label.alpha = alphaOffset
        }
    }

}
