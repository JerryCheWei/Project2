//
//  UserViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/21.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit
import Firebase

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var colorView: UIVisualEffectView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var introductionLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var userTableView: UITableView!
    var headerHeightConstraint: NSLayoutConstraint!
    let cellSpacingHeight: CGFloat = 30

    override func viewDidLoad() {
        super.viewDidLoad()

        setXib()
        setHeader()
        setTableView()
        // 抓貼文image
        LoadingImage.fethImage(tableView: userTableView)
        navigationController?.isNavigationBarHidden = true
        loadUserData()
    }

    func loadUserData() {
        guard let user = Auth.auth().currentUser
            else {
                return
        }
        let userRef = Database.database().reference(withPath: "users/\(user.uid)")
        userRef.observe(.value) { (snapshot) in
            guard
            let value = snapshot.value as? [String: Any],
            let userName = value["userName"] as? String
                else {
                    return
            }
            self.userNameLabel.text = userName
        }
    }

    func setXib() {
        let nib = UINib(nibName: "UserTableViewCell", bundle: nil)
        userTableView.register(nib, forCellReuseIdentifier: "cell")
    }

    //建立header animate
    func setHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerHeightConstraint = headerView.heightAnchor.constraint(equalToConstant: 470)
        headerHeightConstraint.isActive = true
    }
    func setTableView() {
        userTableView.translatesAutoresizingMaskIntoConstraints = false
        userTableView.delegate = self
        userTableView.dataSource = self
    }
    func animateHeader() {
        self.headerHeightConstraint.constant = 470
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    // MARK: - Table View delegate methods
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return LoadingImage.imageUrl.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UserTableViewCell
            else {
                fatalError()
        }

        let loadImage = LoadingImage.imageUrl[indexPath.section]
        let url = URL(string: loadImage)
        URLSession.shared.dataTask(with: url!) { (data, _, error) in
            if error != nil {
                print(error!)
                return
            }

            DispatchQueue.main.async {
                cell.sendImageView.image = UIImage(data: data!)
            }

            }.resume()

        cell.layer.shadowOffset = CGSize(width: 5, height: 5)
        cell.layer.shadowOpacity = 0.7
        cell.layer.shadowRadius = 5
        cell.layer.shadowColor = UIColor(red: 44.0/255.0, green: 62.0/255.0, blue: 80.0/255.0, alpha: 1.0).cgColor

        cell.userImageView.image = UIImage(named: "iconIdentity36pt" )
        cell.userNameLabel.text = LoadingImage.userName
        return cell
    }

}

extension UserViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        if scrollView.contentOffset.y < -10 {
            self.headerHeightConstraint.constant += abs(scrollView.contentOffset.y)

            HeaderViewSet.incrementColorAlpha(offset: headerHeightConstraint.constant, view: self.colorView)
            HeaderViewSet.incrementArticleAlpha(offset: headerHeightConstraint.constant, label: self.introductionLabel)
        }
        else if scrollView.contentOffset.y > -1 && self.headerHeightConstraint.constant >= 75 {
            self.headerHeightConstraint.constant -= scrollView.contentOffset.y/5

            HeaderViewSet.decrementColorAlpha(offset: headerHeightConstraint.constant, view: self.colorView)
            HeaderViewSet.decrementArticleAlpha(offset: headerHeightConstraint.constant, label: self.introductionLabel)
            if self.headerHeightConstraint.constant < 75 {
                self.headerHeightConstraint.constant = 75
                self.introductionLabel.alpha = 0
                self.colorView.alpha = 1
            }
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.headerHeightConstraint.constant > 470 {
            animateHeader()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.headerHeightConstraint.constant > 470 {
            animateHeader()
        }
    }

}
