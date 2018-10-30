////
////  LFLivePreview.swift
////  Project2
////
////  Created by chang-che-wei on 2018/10/29.
////  Copyright © 2018 chang-che-wei. All rights reserved.
////
//
//import Foundation
//import UIKit
//import LFLiveKit
//
//private func formatedSpeed(bytes: Float, elapsedMilli: Float) -> String? {
//    if elapsedMilli <= 0 {
//        return "N/A"
//    }
//
//    if bytes <= 0 {
//        return "0 KB/s"
//    }
//
//    let bytesPerSec: Float = (bytes) * 1000.0 / elapsedMilli
//    if bytesPerSec >= 1000 * 1000 {
//        return String(format: "%.2f MB/s", (bytesPerSec) / 1000 / 1000)
//    } else if bytesPerSec >= 1000 {
//        return String(format: "%.1f KB/s", (bytesPerSec) / 1000)
//    } else {
//        return String(format: "%ld B/s", Int(bytesPerSec))
//    }
//}
//
//class LFLivePreview: UIView, LFLiveSessionDelegate {
//
//    private var debugInfo: LFLiveDebug?
//    private var streamURL = "rtmp://a.rtmp.youtube.com/live2"
//
//    // MARK: Getters and Setters
//    lazy var session: LFLiveSession = {
//        let audioConfiguration = LFLiveAudioConfiguration.defaultConfiguration(for: LFLiveAudioQuality.high)
//        let videoConfiguration = LFLiveVideoConfiguration.defaultConfiguration(for: LFLiveVideoQuality.high2, outputImageOrientation: UIInterfaceOrientation.portrait) // UIInterfaceOrientation.portrait 直向拍攝
//
//        let session = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)
//
//        session?.delegate = self
//        session?.preView = self
//        session?.showDebugInfo = false
//
//        return session!
//    }()
//
//    // MARK: Event
//    func startLive() {
//        let stream = LFLiveStreamInfo()
//        stream.url = streamURL
//        session.startLive(stream)
//    }
//
//    func stopLive() {
//        session.stopLive()
//    }
//
//    func prepareForUsing() {
//        requestAccessForVideo()
//        requestAccessForAudio()
//    }
//
//    func requestAccessForVideo() {
//        let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
//
//        switch status {
//        case .notDetermined:
//            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
//                if granted {
//                    DispatchQueue.main.async(execute: {
//                        self.session.running = true
//                    })
//                }
//            })
//        case .authorized:
//            DispatchQueue.main.async(execute: {
//                self.session.running = true
//            })
//        case .denied, .restricted:
//            break
//        }
//    }
//    func requestAccessForAudio() {
//        let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .audio)
//
//        switch status {
//        case .notDetermined:
//            AVCaptureDevice.requestAccess(for: .audio, completionHandler: { granted in
//            })
//        case .authorized:
//            print("get audio")
//        case .denied, .restricted:
//            break
//        }
//    }
//
//    // MARK: Callback
//
//    func liveSession(_ session: LFLiveSession?, debugInfo: LFLiveDebug?) {
//        print("debugInfo uploadSpeed: \(String(describing: formatedSpeed(bytes: Float((debugInfo?.currentBandwidth)! as CGFloat), elapsedMilli: Float(debugInfo!.elapsedMilli))))")
//    }
//    func liveSession(_ session: LFLiveSession?, errorCode: LFLiveSocketErrorCode) {
//        if let errorCode = errorCode as? CVarArg {
//            print(String(format: "errorCode: %ld", errorCode))
//        }
//    }
//    func liveSession(_ session: LFLiveSession?, liveStateDidChange state: LFLiveState) {
//
//        if let state = state as? CVarArg {
//            print(String(format: "liveStateDidChange: %ld", state))
//        }
//
//        switch state {
//        case .ready:
//            stateLabel.text = "No connect"
//        case .pending:
//            stateLabel.text = "Connecting..."
//        case .start:
//            stateLabel.text = "Connected"
//        case .error:
//            stateLabel.text = "Connection error"
//        case .stop:
//            stateLabel.text = "No Connected"
//        case .refresh:
//            stateLabel.text = "正在刷新..."
//        }
//    }
//    let stateLabel: UILabel = {
//        let stateLabel = UILabel(frame: CGRect(x: 20, y: 20, width: 80, height: 40))
//        stateLabel.text = "Not Connected"
//        stateLabel.textColor = UIColor.white
//        stateLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
//        return stateLabel
//    }()
//
//    func stopPublishing() {
//        self.session.stopLive()
//    }
//
//    func startPublishing(withStreamURL streamURL: String?) {
//        let stream = LFLiveStreamInfo()
//        stream.url = "rtmp://a.rtmp.youtube.com/live2" // @"rtmp://live.hkstv.hk.lxdns.com:1935/live/stream153";
//        print("STREAM URL=\(streamURL ?? "")")
//        session.startLive(stream)
//    }
//
//    // 美顏
////    func changeBeauty() -> Bool {
////        session.beautyFace = !session.beautyFace
////        return !session.beautyFace
////    }
//
//    func changeCameraPosition() {
//        let devicePositon: AVCaptureDevice.Position = session.captureDevicePosition
//        session.captureDevicePosition = (devicePositon == .back) ? .front : .back
//        print("鏡頭轉向")
//    }
//}
