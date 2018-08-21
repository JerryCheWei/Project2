//
//  UserViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/21.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var userTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        setXib()
        // 抓貼文image
        LoadingImage.fethImage(tableView: userTableView)
    }

    func setXib() {
        let nib = UINib(nibName: "UserTableViewCell", bundle: nil)
        userTableView.register(nib, forCellReuseIdentifier: "cell")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LoadingImage.imageUrl.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UserTableViewCell
            else {
                fatalError()
        }

        let loadImage = LoadingImage.imageUrl[indexPath.row]
        let url = URL(string: loadImage)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                cell.sendImageView.image = UIImage(data: data!)
            }
            
            }.resume()

        cell.userImageView.image = UIImage(named: "iconIdentity36pt" )
       

        return cell
    }
}
