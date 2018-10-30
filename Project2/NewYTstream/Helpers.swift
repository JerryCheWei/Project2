//
//  Helpers.swift
//  Project2
//
//  Created by chang-che-wei on 2018/10/29.
//  Copyright © 2018 chang-che-wei. All rights reserved.
//

import Foundation

class Helpers {

    class func dateAfter(_ date: Date, after: (hour: NSInteger, minute: NSInteger, second: NSInteger)) -> Date {
        let calendar = Calendar.current
        if let date = (calendar as NSCalendar).date(byAdding: .hour, value: after.hour, to: date, options: []) {
            if let date = (calendar as NSCalendar).date(byAdding: .minute, value: after.minute, to: date, options: []) {
                if let date = (calendar as NSCalendar).date(byAdding: .second, value: after.second, to: date, options: []) {
                    return date
                }
            }
        }
        return date
    }

}
