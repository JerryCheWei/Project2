//
//  LFLiveViewController.swift
//  Project2
//
//  Created by chang-che-wei on 2018/10/29.
//  Copyright © 2018 chang-che-wei. All rights reserved.
//

import UIKit
import YTLiveStreaming

protocol YouTubeLiveVideoOutput: class {
    func startPublishing(completed: @escaping (String?, String?) -> Void)
    func finishPublishing()
    func cancelPublishing()
}

class LFLiveViewController: UIViewController {

    @IBOutlet weak var stopLiveButton: UIButton!
    @IBOutlet weak var lfView: LFLivePreview!
    var output: YouTubeLiveVideoOutput?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.lfView.prepareForUsing()
            self.output?.startPublishing(completed: { (streamURL, streamName) in
                if let url = streamURL,
                    let name = streamName {
                    let streamFullUrl = "\(url)/\(name)"
                    self.lfView.startPublishing(withStreamURL: streamFullUrl)
                }
            })
        }
    }

    @IBAction func topStopLiveButton(_ sender: Any) {
        lfView.stopPublishing()
        output?.finishPublishing()
        stopLiveButton.setTitle("Finish live broadcast", for: .normal)
    }

    
}
