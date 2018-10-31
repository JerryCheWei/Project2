//
//  Alert.swift
//  Project2
//
//  Created by chang-che-wei on 2018/10/30.
//  Copyright © 2018 chang-che-wei. All rights reserved.
//

import Foundation
import UIKit

class Alert: NSObject {

    var popupWindow: UIWindow!
    var rootVC: UIViewController!

    class var sharedInstance: Alert {
        struct SingletonWrapper {
            static let sharedInstance = Alert()
        }
        return SingletonWrapper.sharedInstance
    }

    fileprivate override init() {
        let screenBounds = UIScreen.main.bounds
        popupWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: screenBounds.width, height: screenBounds.height))
        popupWindow.windowLevel = UIWindow.Level.statusBar + 1

        popupWindow.rootViewController = rootVC

        super.init()
    }

    func showEnterTitle(title: String?, message: String?, closeView: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(okAction)
        closeView.present(alert, animated: true, completion: nil)
    }

    func showFinishLive(title: String?, message: String?, closeView: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel) { (_) in
                closeView.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        closeView.present(alert, animated: true, completion: nil)
    }

    func showOk(_ title: String, message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (_) in
            viewController.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }

}
