//
//  TabBarController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/19.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit
import Firebase
import Crashlytics

class TabBarController: UITabBarController {

    var openCameraViewButton: UIButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupbtn()
    }

    func buttonColor(button: UIButton, lineWidth: CGFloat) {
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: CGPoint.zero, size: button.frame.size)
        gradient.colors = [UIColor.red.cgColor,
                           UIColor.orange.cgColor,
                           UIColor.yellow.cgColor]

        let shape = CAShapeLayer()
        shape.lineWidth = lineWidth
        shape.path = UIBezierPath(roundedRect: button.bounds, cornerRadius: 30).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape

        button.layer.addSublayer(gradient)
    }
    /// 設定按鈕
    func setupbtn() {

        // 設定圖片
        let image = UIImage(named: "round_camera_alt_black_36pt")
        openCameraViewButton.setImage(image, for: .normal)
        openCameraViewButton.tintColor = .white

        // 按鈕位置
        openCameraViewButton.frame.size = CGSize(width: 60, height: 60)
        openCameraViewButton.center = CGPoint(x: tabBar.center.x, y: tabBar.bounds.height/2 - 10)

        // 樣式設定
        let tintcolor = UIColor(red: 221/255, green: 121/255, blue: 76/255, alpha: 1)
        let backcolor = UIColor(red: 72/255, green: 72/255, blue: 72/255, alpha: 1)
        openCameraViewButton.backgroundColor = backcolor
        openCameraViewButton.tintColor = tintcolor
        openCameraViewButton.layer.masksToBounds = true
        openCameraViewButton.layer.cornerRadius = 30
        self.buttonColor(button: openCameraViewButton, lineWidth: 5)

        // 添加按鈕
        tabBar.addSubview(openCameraViewButton)
        openCameraViewButton.addTarget(self, action: #selector(pushToCameraView), for: .touchUpInside)
        tabBar.layer.cornerRadius = 10
    }

    @objc func pushToCameraView() {
        guard let cameraVC = storyboard?.instantiateViewController(withIdentifier: "CameraNavigation") else {return}
        present(cameraVC, animated: true, completion: nil)
    }
}
