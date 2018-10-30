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
        let audioConfiguration = LFLiveAudioConfiguration.defaultConfiguration(for: LFLiveAudioQuality.default)
        let videoConfiguration = LFLiveVideoConfiguration.defaultConfiguration(for: LFLiveVideoQuality.high2, outputImageOrientation: UIInterfaceOrientation.portrait) // UIInterfaceOrientation.portrait 直向拍攝

        let session = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)

        session?.delegate = self
        session?.preView = self
        session?.showDebugInfo = false

        return session!
    }()

    func liveSession(_ session: LFLiveSession?, debugInfo: LFLiveDebug?) {
        print("debugInfo uploadSpeed: \(String(describing: formatedSpeed(bytes: Float((debugInfo?.currentBandwidth)! as CGFloat), elapsedMilli: Float(debugInfo!.elapsedMilli))))")

    }
    func liveSession(_ session: LFLiveSession?, errorCode: LFLiveSocketErrorCode) {
        if let errorCode = errorCode as? CVarArg {
            print(String(format: "errorCode: %ld", errorCode))
        }

    }

    func liveSession(_ session: LFLiveSession?, liveStateDidChange state: LFLiveState) {

        if let state = state as? CVarArg {
            print(String(format: "liveStateDidChange: %ld", state))
        }

        switch state {
        case .ready:
            stateLabel.text = "No connect"
            print("No connect")
        case .pending:
            stateLabel.text = "Connecting..."
            print("Connecting...")
        case .start:
            stateLabel.text = "Connected"
            print("Connected")
        case .error:
            stateLabel.text = "Connection error"
            print("Connection error")
        case .stop:
            stateLabel.text = "No Connected"
            print("No Connected")
        case .refresh:
            stateLabel.text = "正在刷新..."
            print("正在刷新...")
        }

    }
    #warning("TODO: 修正 stateLabel 無法顯示問題")
    let stateLabel: UILabel = {
        let stateLabel = UILabel(frame: CGRect(x: 20, y: 20, width: 80, height: 40))
        stateLabel.text = "Not Connected"
        stateLabel.textColor = UIColor.white
        stateLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        return stateLabel
    }()

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

func formatedSpeed(bytes: Float, elapsedMilli: Float) -> String? {

    if elapsedMilli <= 0 {
        return "N/A"
    }

    if bytes <= 0 {
        return "0 KB/s"
    }

    let bytesPerSec: Float = (bytes) * 1000.0 / elapsedMilli
    if bytesPerSec >= 1000 * 1000 {

        return String(format: "%.2f MB/s", (bytesPerSec) / 1000 / 1000)

    } else if bytesPerSec >= 1000 {

        return String(format: "%.1f KB/s", (bytesPerSec) / 1000)

    } else {

        return String(format: "%ld B/s", Int(bytesPerSec))
    }
}
