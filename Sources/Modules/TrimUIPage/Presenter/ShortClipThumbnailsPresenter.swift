//
//  ShortClipThumbnailsPresenter.swift
//  ShortClipVideoTrimmerUI
//
//  Created by Sagar on 9/23/22.
//

import UIKit
import AVKit
import AVFoundation

public enum ShortClipImageGeneratorRunningStatus {
    case running
    case cancel
}

struct ShortClipVisibleVideoFrameItem {
    var frame : UIImage?
    var requestedTime : Double
    var index : Int = -1// -1 means "index is not valid or found"
}

protocol ShortClipThumbnailsPresenterDelegate : AnyObject {
    func reloadThumbnails()
    func resetCollectionViewContentOffSet()
}

class ShortClipThumbnailsPresenter {
    var visibleVideoFrameItemsDict = [Int : ShortClipVisibleVideoFrameItem]()
    var numberOfThumbnails : Int = 0
    var videoLength : CGFloat = 0.0
    let timeScale : CMTimeScale = 600
    var asset : AVAsset?
    var numberOfFramesPerCycle = 8
    var delayBetweenFrames : CGFloat = 0.0
    var imageGenerator : AVAssetImageGenerator?
    weak var delegate : ShortClipThumbnailsPresenterDelegate?
    var imageGeneratorStatus : ShortClipImageGeneratorRunningStatus = .cancel
    init(asset : AVAsset, numberOfFramesPerCycle : Int =  8) {
        self.asset = asset
        self.numberOfFramesPerCycle = numberOfFramesPerCycle
        self.videoLength = asset.duration.seconds
    }
    
    func setupData(delayBetweenFrames : CGFloat) {
        self.delayBetweenFrames = delayBetweenFrames
    }
    
    func cancelThumnailsGenerating() {
        imageGeneratorStatus = .cancel
        imageGenerator?.cancelAllCGImageGeneration()
    }
    
    func removeAllFrames() {
        visibleVideoFrameItemsDict.removeAll()
    }
    
    func calculateDelayBetweenFrames(startTime : Double, maxTrimmingDuration : Double, numberOfFramesPerCycle : Int)-> Double {
        guard startTime < maxTrimmingDuration else {
            return Double(Int.max)
        }
        
        if(numberOfFramesPerCycle < 2) {
            return Double(Int.max)
        }
        
        let cmTime = CMTime(seconds: maxTrimmingDuration / Double(numberOfFramesPerCycle), preferredTimescale: self.timeScale)
        return cmTime.seconds
    }
    
    func calculateNumberOfExpectedThumbnails(videoLength : CGFloat) {
        let numberOfFrames = ceil(videoLength / delayBetweenFrames)// + 1.0
        let maxFrames = Int((numberOfFrames))
        numberOfThumbnails = maxFrames
    }
    
    func addFrames(startTime : Double, finishTime : Double) {
        guard startTime < finishTime else {
            return
        }
        var timesForThumbnail = getTimesForThumnails(startTime: startTime, finishTime: finishTime, delayBetweenFrames: delayBetweenFrames)
        for index in stride(from: timesForThumbnail.count, to: 0, by: -1) {
            let cmTime = timesForThumbnail[index - 1].timeValue
            let seconds = cmTime.seconds
            let toIndex = getSecondsToIndex(seconds: seconds, delayBetweenFrames: delayBetweenFrames, duration: videoLength)
            if let _ = self.visibleVideoFrameItemsDict[toIndex] {
                timesForThumbnail.remove(at: index - 1)
            }
        }
        self.generateThumnails(asset: asset, timesForThumbnail: timesForThumbnail, thumbnailDimension: CGSize(width: 50, height: 50)) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.delegate?.reloadThumbnails()
            }
        }
    }
    
    private func generateThumnails(asset : AVAsset?, timesForThumbnail : [NSValue], thumbnailDimension : CGSize = CGSize(width: 50, height: 50), completion : @escaping ()-> Void) {
        guard let asset = asset else {
            return
        }
        let totalItems = timesForThumbnail.count
        var numberOfValidThumbnailGenerated = 0
        var numberOfOperations = 0
        if let imageGenerator = imageGenerator {
            imageGenerator.cancelAllCGImageGeneration()
        }
        imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGeneratorStatus = .running
        guard let imageGenerator = imageGenerator else {
            completion()
            return
        }
        imageGenerator.requestedTimeToleranceAfter = CMTime.zero
        imageGenerator.requestedTimeToleranceBefore = CMTime.zero
        imageGenerator.appliesPreferredTrackTransform = true
        let deviceScale = UIScreen.main.scale
        imageGenerator.maximumSize = CGSize(width: thumbnailDimension.width * deviceScale, height: thumbnailDimension.height * deviceScale)
        var previousFrame : UIImage?
        imageGenerator.generateCGImagesAsynchronously(forTimes: timesForThumbnail) { [weak self] requestedTime, cgImage, actualTime, result, error in
            if result == .succeeded, let cgImage = cgImage, error == nil {
                DispatchQueue.main.async(execute: { [weak self] () -> Void in
                    if let strongSelf = self {
                        let uiImage = UIImage(cgImage: cgImage)
                        previousFrame = uiImage
                        let toIndex = strongSelf.getSecondsToIndex(seconds: requestedTime.seconds, delayBetweenFrames: strongSelf.delayBetweenFrames, duration: strongSelf.videoLength)
                        if strongSelf.visibleVideoFrameItemsDict[toIndex] == nil {
                            strongSelf.visibleVideoFrameItemsDict.updateValue(ShortClipVisibleVideoFrameItem(frame: uiImage, requestedTime: requestedTime.seconds, index: toIndex), forKey: toIndex)
                        }
                        numberOfValidThumbnailGenerated += 1
                    }
                })
            } else {
                guard let strongSelf = self, strongSelf.imageGeneratorStatus == .running else {
                    return
                }
                
                let toIndex = strongSelf.getSecondsToIndex(seconds: requestedTime.seconds, delayBetweenFrames: strongSelf.delayBetweenFrames, duration: strongSelf.videoLength)
                if let previousFrame = previousFrame {
                    if strongSelf.visibleVideoFrameItemsDict[toIndex] == nil {
                        strongSelf.visibleVideoFrameItemsDict.updateValue(ShortClipVisibleVideoFrameItem(frame: previousFrame, requestedTime: requestedTime.seconds, index: toIndex), forKey: toIndex)
                    }
                    
                } else { }
                
            }
            numberOfOperations += 1
            if (numberOfOperations % 7 == 0) {
                DispatchQueue.main.async {
                    self?.delegate?.reloadThumbnails()
                }
            }
            if(numberOfOperations == totalItems) {
                completion()
            }
        }
    }
    
    func getTimesForThumnails(startTime : Double, finishTime : Double, delayBetweenFrames delay : Double)-> [NSValue] {
        var timesForThumbnail = [NSValue]()
        var currentFrameTime = TimeInterval(startTime)
        var frameCount = 0;
        while(true) {
            currentFrameTime = TimeInterval(startTime) + (TimeInterval(delay) * TimeInterval(frameCount))
            let time = CMTime(seconds: currentFrameTime, preferredTimescale: self.timeScale)
            frameCount += 1
            if (currentFrameTime > TimeInterval(finishTime)) {
                break
            } else {
                timesForThumbnail.append(NSValue(time: time))
            }
        }
        return timesForThumbnail
    }
    
    func getSecondsToIndex(seconds : CGFloat, delayBetweenFrames : CGFloat, duration : CGFloat)-> Int {
        
        guard numberOfFramesPerCycle > 1 else {
            return 0
        }
        let formatted = Int((seconds / delayBetweenFrames) * 1000)
        let nthFrameIndex = ceil(Double(formatted) / 1000.0)
        return max(0, Int(nthFrameIndex))
    }
    
}
