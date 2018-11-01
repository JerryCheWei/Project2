//
//  ReadUserPrivacyViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/9/10.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit
import WebKit
import Firebase

class ReadUserPrivacyViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    @IBOutlet weak var userPrivacyWebView: WKWebView!
    let fullScreenSize = UIScreen.main.bounds.size
    var myActivityIndicator: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "使用者隱私權條款"
        navigationController?.navigationBar.tintColor = .black
        // 進度條
        myActivityIndicator = UIActivityIndicatorView(style: .gray)
        myActivityIndicator?.center = CGPoint(
            x: fullScreenSize.width * 0.5,
            y: fullScreenSize.height * 0.3)
        self.view.addSubview(myActivityIndicator!)
        self.userPrivacyWebView.navigationDelegate = self
        self.fetchWebUrl()
    }

    func showWeb(userPrivacyWebUrl: String) {
        // 前往網址
        if let url = URL(string: userPrivacyWebUrl) {
            let urlRequest = URLRequest(url: url)
            userPrivacyWebView.load(urlRequest)
        }
    }

    //web
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        myActivityIndicator?.startAnimating()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        myActivityIndicator?.stopAnimating()
    }

    func fetchWebUrl() {
        Database.database().reference().child("userPrivacyWebUrl").observe(.value) { (snapshot) in
            guard let userPrivacyWebUrl = snapshot.value as? String
                else {
                    print("userPrivacyWebUrl error")
                    return
            }
            self.showWeb(userPrivacyWebUrl: userPrivacyWebUrl)
        }
    }
}
