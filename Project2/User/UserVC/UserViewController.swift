//
//  UserViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/21.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var userTableView: UITableView!
    var headerHeightConstraint: NSLayoutConstraint!
    let cellSpacingHeight: CGFloat = 15

    override func viewDidLoad() {
        super.viewDidLoad()

        setXib()
        setHeader()
        setTableView()
        // 抓貼文image
        LoadingImage.fethImage(tableView: userTableView)
        navigationController?.isNavigationBarHidden = true
    }

    func setXib() {
        let nib = UINib(nibName: "UserTableViewCell", bundle: nil)
        userTableView.register(nib, forCellReuseIdentifier: "cell")
    }

    //建立header animate
    func setHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerHeightConstraint = headerView.heightAnchor.constraint(equalToConstant: 360)
        headerHeightConstraint.isActive = true
    }
    func setTableView() {
        userTableView.translatesAutoresizingMaskIntoConstraints = false
        userTableView.delegate = self
        userTableView.dataSource = self
        userTableView.layer.cornerRadius = 10
    }
    func animateHeader() {
        self.headerHeightConstraint.constant = 360
        UIView.animate(withDuration: 0.1, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
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
        cell.layer.cornerRadius = 10
        return cell
    }
}

extension UserViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        if scrollView.contentOffset.y < 0 {
            self.headerHeightConstraint.constant += abs(scrollView.contentOffset.y)
        }
        else if scrollView.contentOffset.y > 0 && self.headerHeightConstraint.constant >= 65 {
            self.headerHeightConstraint.constant -= scrollView.contentOffset.y/50
            if self.headerHeightConstraint.constant < 65 {
                self.headerHeightConstraint.constant = 65
            }

        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.headerHeightConstraint.constant > 360 {
            animateHeader()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.headerHeightConstraint.constant > 360 {
            animateHeader()
        }
    }

}
