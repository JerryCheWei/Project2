//
//  YoutubePlayer.swift
//  Project2
//
//  Created by chang-che-wei on 2018/11/1.
//  Copyright © 2018 chang-che-wei. All rights reserved.
//

import UIKit

class YouTubePlayer: NSObject {

    static var youtubePlayerViewController: YoutubePlayerViewController?
    static var youtubePlayerDelegate: PlayerDelegate?

    class func playYoutubeID(_ youtubeId: String, viewController: UIViewController) {
        if self.youtubePlayerViewController == nil {
            self.youtubePlayerViewController = YoutubePlayerViewController()
            self.youtubePlayerDelegate = PlayerDelegate()
            self.youtubePlayerViewController!.delegate = youtubePlayerDelegate
        }
        youtubePlayerViewController!.playVideo(youtubeId, viewController: viewController)
    }
}

class PlayerDelegate: YoutubePlayerDelegate {
    func playerDidFinish() {
    }
}
