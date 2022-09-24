//
//  HomePageViewController.swift
//  ShortClipVideoTrimmerUI_Example
//
//  Created by Sagar on 9/24/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation
import ShortClipVideoTrimmerUI


class HomePageViewController: UIViewController {

    
    @IBOutlet weak var thumbnailsSuperView: UIView!
    @IBOutlet weak var trimmingTimeLabel: UILabel!
    @IBOutlet weak var videoPlayerView: UIView!
    var shortClipTrimmerContentView : ShortClipVideoTrimmerContentView?
    var videoPlayer : AVPlayer?
    var isFirstTimeLoaded = true
    var videoURL = Bundle.main.url(forResource: "Free", withExtension: ".MP4")
    let maxTrimmingDuration : Double = 10.0
    let numberOfFramesPerCycle : Int = 8
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isFirstTimeLoaded {
            setupViews()
            setupPlayer()
            addVideoPlayerObserver()
            playVideo()
            updateTimeLabel()
            isFirstTimeLoaded = false
        }
    }
    
    private func setupViews() {
        shortClipTrimmerContentView = ShortClipVideoTrimmerContentView(frame: thumbnailsSuperView.bounds)
        guard let shortClipTrimmerContentView = shortClipTrimmerContentView else {
            return
        }
        shortClipTrimmerContentView.delegate = self
        shortClipTrimmerContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        thumbnailsSuperView.addSubview(shortClipTrimmerContentView)
    }
    
    private func setupPlayer() {
        guard let videoURL = videoURL else {
            print("Video url is nil")
            return
        }
        let asset = AVAsset(url: videoURL)
        shortClipTrimmerContentView?.startOperation(asset: asset, maxTrimmingDuration: maxTrimmingDuration, numberOfFramesPerCycle: numberOfFramesPerCycle)
        let playerItem = AVPlayerItem(asset: asset)
        videoPlayer = AVPlayer(playerItem: playerItem)
        guard let videoPlayer = videoPlayer else {
            return
        }
        let playerLayer = AVPlayerLayer(player: videoPlayer)
        playerLayer.frame = videoPlayerView.bounds
        playerLayer.videoGravity = .resizeAspect
        videoPlayerView.layer.addSublayer(playerLayer)
        
        videoPlayer.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.01, preferredTimescale: 600), queue: .main) { [weak self] cmTime in
            guard let thisSelf = self else {
                return
            }
            // from here you need to pass current time of VideoPlayer
            thisSelf.videoDidChange(time : videoPlayer.currentTime())
        }
    }
    /// this method is responsible for moving the posiitonBar
    private func videoDidChange(time cmTime : CMTime) {
        shortClipTrimmerContentView?.updatePositionBarConstraint(cmTime: cmTime)
    }
    
    private func seekToTime(_ seekTime: CMTime) {
        guard let videoPlayer = videoPlayer else {
            return
        }
        videoPlayer.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    private func addVideoPlayerObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: videoPlayer?.currentItem)
    }
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        var trimmingStartCmTime = CMTime.zero
        if let trimmingStartTime = shortClipTrimmerContentView?.getTrimmingStartFinishTime().trimStartTime {
            trimmingStartCmTime = CMTime(seconds: trimmingStartTime, preferredTimescale: 600)
        }
        videoPlayer?.seek(to: trimmingStartCmTime, toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: { _ in
            DispatchQueue.main.async {
                self.videoPlayer?.play()
            }
        })
        
    }

    @IBAction func trimButtonAction(_ sender: UIButton) {
        // you can get current video trimming start and end time by using following method
        guard let trimmingStartFinishTime = shortClipTrimmerContentView?.getTrimmingStartFinishTime() else {
            return
        }
        let trimmingStartTime = trimmingStartFinishTime.trimStartTime
        let trimmingFinishTime = trimmingStartFinishTime.trimFinishTime
        
        /// Apply your logic to trim or anything you want
    }
    
    private func updateTimeLabel() {
        guard let trimmingStartFinishTime = shortClipTrimmerContentView?.getTrimmingStartFinishTime() else {
            return
        }
        let trimmingStartTime = trimmingStartFinishTime.trimStartTime
        let trimmingFinishTime = trimmingStartFinishTime.trimFinishTime
        trimmingTimeLabel.text = String(format: "%.2f : %.2fs", trimmingStartTime,trimmingFinishTime)
    }
    
    private func playVideo() {
        videoPlayer?.play()
    }
    
    private func pasueVideo() {
        videoPlayer?.pause()
    }
    
}

extension HomePageViewController : ShortClipVideoTrimmerContentViewDelegate {
    func didMoveToFinishPosition(startTime: CGFloat, finishTime: CGFloat) {
        seekToTime(CMTime(seconds: startTime, preferredTimescale: 600))
        updateTimeLabel()
    }
    
    func trimmingStartTimeDidChange(trimmingStartTime: CGFloat) {
        seekToTime(CMTime(seconds: trimmingStartTime, preferredTimescale: 600))
        updateTimeLabel()
    }
    
    func trimmingFinishTimeDidChange(trimmingFinishTime: CGFloat) {
        guard let trimmingStartFinishTime = shortClipTrimmerContentView?.getTrimmingStartFinishTime() else {
            return
        }
        seekToTime(CMTime(seconds: trimmingStartFinishTime.trimStartTime, preferredTimescale: 600))
        updateTimeLabel()
    }
    
}
