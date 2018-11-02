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

class LFLiveViewController: UIViewController {

    @IBOutlet weak var currentStatusLabel: UILabel!
    @IBOutlet weak var stopOrStartLiveButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var lfView: Preview!

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
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.lfView.prepareForUsing()
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
            stopOrStartLiveButton.backgroundColor = .gray
            startPublishing { (streamURL, streamName) in
                if let streamURL = streamURL,
                    let streamName = streamName {

                    let streamUrl = "\(streamURL)/\(streamName)"
                    self.lfView.startPublishing(withStreamURL: streamUrl)

                }
                print("start live now !!")
            }
        }
    }

    func showCurrentStatus(currStatus: String) {
        currentStatusLabel.text = currStatus
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
    }

    func didTransitionToStatus(broadcastStatus: String?, streamStatus: String?, healthStatus: String?) {
        if let broadcastStatus = broadcastStatus, let streamStatus = streamStatus, let healthStatus = healthStatus {
            let text = "串流狀態: \(broadcastStatus) [\(streamStatus),\(healthStatus)]"
            print(text)
            self.showCurrentStatus(currStatus: text)

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
