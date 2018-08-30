//
//  TabBarController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/19.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    var openCameraViewButton: UIButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupbtn()
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
//        let color = UIColor(red: 151/255, green: 216/255, blue: 246/255, alpha: 1)
        let color = UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1)
        openCameraViewButton.backgroundColor = color
        openCameraViewButton.layer.masksToBounds = true
        openCameraViewButton.layer.cornerRadius = 30

        // 添加按鈕
        tabBar.addSubview(openCameraViewButton)
        openCameraViewButton.addTarget(self, action: #selector(pushToCameraView), for: .touchUpInside)
    }

    @objc func pushToCameraView() {
        guard let cameraVC = storyboard?.instantiateViewController(withIdentifier: "CameraNavigation") else {return}
        present(cameraVC, animated: true, completion: nil)
    }
}
