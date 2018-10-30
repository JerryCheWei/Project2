//
//  Preview.swift
//  Project2
//
//  Created by chang-che-wei on 2018/10/30.
//  Copyright © 2018 chang-che-wei. All rights reserved.
//

import Foundation
import UIKit
import LFLiveKit

class Preview: UIView, LFLiveSessionDelegate {
    lazy var session: LFLiveSession = {
        let audioConfiguration = LFLiveAudioConfiguration.defaultConfiguration(for: LFLiveAudioQuality.high)
        let videoConfiguration = LFLiveVideoConfiguration.defaultConfiguration(for: LFLiveVideoQuality.high2, outputImageOrientation: UIInterfaceOrientation.portrait) // UIInterfaceOrientation.portrait 直向拍攝

        let session = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)

        session?.delegate = self
        session?.preView = self
        session?.showDebugInfo = false

        return session!
    }()

//    func liveSession(_ session: LFLiveSession?, debugInfo: LFLiveDebug?) {
//        <#code#>
//    }
//
//    func liveSession(_ session: LFLiveSession?, errorCode: LFLiveSocketErrorCode) {
//        <#code#>
//    }
//
//    func liveSession(_ session: LFLiveSession?, liveStateDidChange state: LFLiveState) {
//        <#code#>
//    }
}

extension Preview {

    func prepareForUsing() {
        requestAccessForVideo()
        requestAccessForAudio()
        print("檢查 video, audio 權限")
    }

    func startPublishing(withStreamURL streamUrl: String) {
        let stream = LFLiveStreamInfo()
        stream.url = streamUrl // "rtmp://a.rtmp.youtube.com/live2"
        session.startLive(stream)
        session.running = true
        print("推流開始 , streamUrl : \(stream)")
    }

    func stopPublishing() {
        self.session.stopLive()
        print("停止串流")
    }

    func changeCameraPosition() {
        let devicePositon: AVCaptureDevice.Position = session.captureDevicePosition
        session.captureDevicePosition = (devicePositon == .back) ? .front : .back
        print("鏡頭轉向")
    }

    // 美顏
//    func changeBeauty() -> Bool {
//        session.beautyFace = !session.beautyFace
//        return !session.beautyFace
//    }

}

extension Preview {

    // 檢查 video 權限
    func requestAccessForVideo() {
        let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if granted {
                    DispatchQueue.main.async(execute: {
                        self.session.running = true
                    })
                }
            })
        case .authorized:
            DispatchQueue.main.async(execute: {
                self.session.running = true
            })
        case .denied, .restricted:
            break
        }
    }

    // 檢查 Audio 權限
    func requestAccessForAudio() {
        let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .audio)

        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio, completionHandler: { granted in
            })
        case .authorized:
            print("get audio")
        case .denied, .restricted:
            break
        }
    }

}
