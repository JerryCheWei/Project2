//
//  YoutubePlayerViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/11/1.
//  Copyright © 2018 chang-che-wei. All rights reserved.
//

import UIKit
import XCDYouTubeKit

protocol YoutubePlayerDelegate: class {
    func playerDidFinish()
}

class YoutubePlayerViewController: UIViewController {

    weak var delegate: YoutubePlayerDelegate?
    var videoPlayerViewController: XCDYouTubeVideoPlayerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func playVideo(_ youtubeId: String, viewController: UIViewController) {
        self.videoPlayerViewController = XCDYouTubeVideoPlayerViewController(videoIdentifier: youtubeId)
        NotificationCenter.default.addObserver(self, selector: #selector(YoutubePlayerViewController.moviePlayerPlaybackDidFinish(_:)),
                                               name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish,
                                               object: self.videoPlayerViewController!.moviePlayer)
        viewController.present(self.videoPlayerViewController!, animated: true) {
        }
    }

    @objc func moviePlayerPlaybackDidFinish(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: nil)
        if let finishReason: MPMovieFinishReason = (notification.userInfo![MPMoviePlayerPlaybackDidFinishReasonUserInfoKey]! as AnyObject).int32Value as? MPMovieFinishReason {
            if finishReason == .playbackError {
                if let error = notification.userInfo![XCDMoviePlayerPlaybackDidFinishErrorUserInfoKey] {
                    print(error)
                }
            }
        }
        delegate?.playerDidFinish()
    }
}
