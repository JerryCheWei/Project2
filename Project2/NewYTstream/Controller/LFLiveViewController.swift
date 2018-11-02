//
//  LFLiveViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/10/29.
//  Copyright © 2018 chang-che-wei. All rights reserved.
//

import UIKit
import YTLiveStreaming
import Firebase
import GoogleSignIn

class LFLiveViewController: UIViewController {

    @IBOutlet weak var waitView: UIView!
    @IBOutlet weak var currentStatusLabel: UILabel!
    @IBOutlet weak var stopOrStartLiveButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var lfView: Preview!
    var refreshControl: UIActivityIndicatorView!
    var isUp = true

    var scheduledStartTime: NSDate?
    let input = YTLiveStreaming()
    var liveBroadcast: LiveBroadcastStreamModel?

    func into(liveBroadcast: LiveBroadcastStreamModel) {
        self.liveBroadcast = liveBroadcast
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        cameraButton.isExclusiveTouch = true
        closeButton.isExclusiveTouch = true
        currentStatusLabel.text = " "

        // add top view to show stopOrStartLiveButton
        let top = UITapGestureRecognizer(target: self, action: #selector(showButton))
        view.addGestureRecognizer(top)

        self.preaper()
        stopOrStartLiveButton.isHidden = true
        waitView.isHidden = false
        waitView.alpha = 0.7
    }

    func preaper() {
        refreshControl = UIActivityIndicatorView()
        refreshControl.color = .red
        refreshControl.center.x = view.center.x
        refreshControl.center.y = view.center.y-100
        self.view.addSubview(refreshControl)

        connectLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width-20, height: 50)
        connectLabel.center.x = view.center.x
        connectLabel.center.y = view.center.y-40
        connectLabel.alpha = 0
        connectLabel.textAlignment = .center
        self.view.addSubview(connectLabel)
    }

    let connectLabel: UILabel = {
        let label = UILabel()
        label.text = "創建直播中..."
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()

    func loadingView() {
        self.refreshControl.startAnimating()
        UIView.animate(withDuration: 0.8, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.connectLabel.alpha = 1
        }, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.lfView.prepareForUsing()
        }
        self.startCreateBroadcast()
        self.loadingView()
    }

    func startCreateBroadcast() {
        let startDate = Helpers.dateAfter(Date(), after: (hour: 0, minute: 0, second: 10))

        input.createBroadcast("正在 SYOS 進行直播快來看～", description: "", startTime: startDate) { (creatBreadcase) in
            if let breadcast = creatBreadcase {
                self.into(liveBroadcast: breadcast)
                self.refreshControl.stopAnimating()
                self.connectLabel.layer.removeAllAnimations()
                self.refreshControl.isHidden = true
                self.connectLabel.isHidden = true
                self.stopOrStartLiveButton.isHidden = false
            }
            else {
                print("createBroadcast error")
                GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/youtube.readonly")
                GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/youtube")
                GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/youtube.force-ssl")
                GIDSignIn.sharedInstance()?.signInSilently()
                self.startCreateBroadcast()
            }
        }
    }

    @IBAction func changeCameraPositionButtonPressed(_ sender: Any) {
        lfView.changeCameraPosition()
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
        self.cancelPublishing()
    }

    @IBAction func topStopLiveButton(_ sender: Any) {
        if stopOrStartLiveButton.isSelected {
            stopOrStartLiveButton.isSelected = false
            stopOrStartLiveButton.setTitle("已結束直播", for: .normal)
            stopOrStartLiveButton.isEnabled = false
            lfView.stopPublishing()
            self.finishPublishing()
        } else {
            self.closeButton.isHidden = true
            stopOrStartLiveButton.isSelected = true
            stopOrStartLiveButton.setTitle("結束", for: .normal)
            stopOrStartLiveButton.backgroundColor = .darkGray
            self.liveButtonAnimated()
            self.showCurrentStatus(currStatus: "準備中...")

            DispatchQueue.main.async {
                self.startPublishing { (streamURL, streamName) in
                    if let streamURL = streamURL,
                        let streamName = streamName {

                        let streamUrl = "\(streamURL)/\(streamName)"
                        self.lfView.startPublishing(withStreamURL: streamUrl)
                    }
                    print("start live now !!")
                }
            }
        }
    }

    func showCurrentStatus(currStatus: String) {
        currentStatusLabel.text = currStatus
    }

    func liveButtonAnimated() {
        UIView.animate(withDuration: 0.7, delay: 0.2, options: [.curveEaseInOut, .allowUserInteraction], animations: {
            self.stopOrStartLiveButton.frame = CGRect(x: self.view.frame.width/2-60, y: self.view.frame.height, width: 120, height: 40)
        }, completion: nil)
        isUp = false
    }

    @objc func showButton() {
        if isUp {
            self.liveButtonAnimated()
        }
        else {
            UIView.animate(withDuration: 0.3, delay: 0.2, options: [.curveEaseInOut, .allowUserInteraction], animations: {
                self.stopOrStartLiveButton.center.x = self.view.center.x
                self.stopOrStartLiveButton.center.y = self.view.frame.height-20-40
            }, completion: nil)
            isUp = true
        }
    }
}

extension LFLiveViewController: YTLiveStreamingDelegate {

    func startPublishing(completed: @escaping (String?, String?) -> Void) {
        guard let broadcast = self.liveBroadcast
            else {
                print("liveBroadcast : \(String(describing: liveBroadcast))")
                return
        }
        input.startBroadcast(broadcast, delegate: self, completion: { (streamName, streamUrl, scheduledStartTime) in
            if let name = streamName,
                let url = streamUrl,
                let time = scheduledStartTime {
                print("name: \(name)\nurl: \(url)\ntime: \(time)\nstartBroadcast !!!!")
                completed(url, name)
            }
        })
    }

    func finishPublishing() {
        guard let broadcast = self.liveBroadcast
            else {
                self.dismissVideoStreamViewController()
                print("completeBroadcast error !!!!!")
                return
        }
        input.completeBroadcast(broadcast, completion: { success in
            Alert.sharedInstance.showOk("已結束串流", message: "恭喜，順利結束直播！", viewController: self)
            self.navigationController?.isNavigationBarHidden = false
        })
        self.showCurrentStatus(currStatus: "■ END")
        self.currentStatusLabel.layer.removeAllAnimations()
        self.currentStatusLabel.alpha = 1
        self.pushStreamUrlToFirebase(isCanSeeLive: false)
         waitView.isHidden = false
    }

    func cancelPublishing() {
        guard let broadcast = self.liveBroadcast
            else {
                self.dismissVideoStreamViewController()
                return
        }
        input.deleteBroadcast(id: broadcast.id, completion: { success in
            if success {
                print("Broadcast \"\(broadcast.id)\" was deleted!")
                self.navigationController?.isNavigationBarHidden = false
            } else {
                Alert.sharedInstance.showOk("Sorry, system detected error while deleting the video.", message: "You can try to delete it in your YouTube account", viewController: self)
            }
        })
    }

    func dismissVideoStreamViewController() {
        print("dismiss live vc")
        self.dismiss(animated: true, completion: nil)
    }

    func didTransitionToLiveStatus() {
        self.showCurrentStatus(currStatus: "● LIVE")
        self.currentStatusLabel.font = UIFont.boldSystemFont(ofSize: 20)
        UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.currentStatusLabel.alpha = 0
        }, completion: nil)
        self.pushStreamUrlToFirebase(isCanSeeLive: true)
        waitView.isHidden = true
    }

    func didTransitionToStatus(broadcastStatus: String?, streamStatus: String?, healthStatus: String?) {
        if let broadcastStatus = broadcastStatus, let streamStatus = streamStatus, let healthStatus = healthStatus {
            let text = "串流狀態: \(broadcastStatus) [\(streamStatus),\(healthStatus)]"
            print(text)
            let message = "檢查網路狀態..."
            self.showCurrentStatus(currStatus: message)

//            switch broadcastStatus {
//            case "ready":
//                print("準備")
//            case "complete":
//                print("結束")
//            case "live":
//                print("正在直播")
//            case "liveStarting":
//                print("準備中...")
//            case "testStarting":
//                print("準備中...")
//
//            default:
//                print("")
//            }

        }
    }

    // 上傳 streamUrl 到 Firebase
    func pushStreamUrlToFirebase(isCanSeeLive: Bool) {
        if let broadcast = self.liveBroadcast {
            let broadcastID = "\(broadcast.id)"

            guard let user = Auth.auth().currentUser
                else {
                    return
            }

            if isCanSeeLive {
                let liveStreamsRef = Database.database().reference().child("liveStreams").child(user.uid)
                liveStreamsRef.updateChildValues(
                            ["liveBroadcastID": broadcastID,
                             "userID": user.uid
                            ])
            }
            else {
                Database.database().reference().child("liveStreams").child(user.uid).removeValue()
            }
        }
    }

}
