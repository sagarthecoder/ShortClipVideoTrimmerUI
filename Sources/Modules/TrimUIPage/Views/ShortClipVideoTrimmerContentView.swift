//
//  ShortClipFramesCollectionView.swift
//  ShortClipVideoTrimmerUI
//
//  Created by Sagar on 9/23/22.
//

import UIKit
import AVFoundation

public protocol ShortClipVideoTrimmerContentViewDelegate : AnyObject {
    /// This method will be fired when positionBar is reached to Finishing line of Trimming
    func didMoveToFinishPosition(startTime : CGFloat, finishTime : CGFloat)
    
    /// This method will be fired whenever trimming start time changes
    func trimmingStartTimeDidChange(trimmingStartTime : CGFloat)
    
    /// This method will be fired whenever trimming Finish time changes
    func trimmingFinishTimeDidChange(trimmingFinishTime : CGFloat)
}


public  class ShortClipVideoTrimmerContentView: UIView {
    
    private var loadingImage : UIImage?
    private let identifier = "identifier"
    private var presenter : ShortClipThumbnailsPresenter?
    private var timeScale : CMTimeScale = 600
    private var videoLength : CGFloat = 0.0
    private var validMaxTrimmingDuration : CGFloat = 0.0
    var delayBetweenFrames : CGFloat = 0.0
    
    private var trimmerView : ShortClipVideoTrimmerView?
    public weak var delegate : ShortClipVideoTrimmerContentViewDelegate?
    var nextDestination : Double = 0.0
    private var trimmingStartTime : CGFloat = 0.0 {
        didSet {
            delegate?.trimmingStartTimeDidChange(trimmingStartTime: trimmingStartTime)
            trimmerView?.resetPositionBarConstraints()
        }
    }
    
    private var trimmingFinishTime : CGFloat =  0.0 {
        didSet {
            delegate?.trimmingFinishTimeDidChange(trimmingFinishTime: trimmingFinishTime)
            trimmerView?.resetPositionBarConstraints()
        }
    }
    
    private var leftHandleLeadingConstraint : CGFloat = 0.0 {
        didSet {
            let seconds = updateSecondsForHandle(leadingConstraint: leftHandleLeadingConstraint)
            trimmingStartTime = min(max(0.0, seconds), videoLength)
        }
    }
    
    private var rightHandleLeadingConstraint : CGFloat = 0.0 {
        didSet {
            let seconds = updateSecondsForHandle(leadingConstraint: rightHandleLeadingConstraint)
            trimmingFinishTime = max(0, min(videoLength, seconds))
        }
    }
    
    
    lazy private var collectionView : UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        collectionView.register(ShortClipThumbnailsCollectionViewCell.self, forCellWithReuseIdentifier: identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        loadingImage = UIImage(named: "loader.jpeg", in: Bundle(for: type(of: self)), compatibleWith: nil)
        clipsToBounds = false
        self.layer.masksToBounds = false
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        trimmerView = ShortClipVideoTrimmerView(frame: bounds)
        guard let trimmerView = trimmerView else {
            return
        }
        trimmerView.clipsToBounds = false
        trimmerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        trimmerView.delegate = self
        addSubview(trimmerView)
        layoutIfNeeded()
    }
    
    /// Start operation
    /// - Parameters:
    ///     - asset : A valid AVAsset
    ///     - maxTrimmingDuration : Maximum trimming duration. That means if you set maxTrimmingDuration = 10 then you can handle at most 10 seconds of consecutive frames from any part of the video. Default is 10
    ///     - numberOfFramesPerCycle : total number of frames can be shown in each circle. Default is 7
    public func startOperation(asset : AVAsset, maxTrimmingDuration : Double = 10.0, numberOfFramesPerCycle : Int = 7) {
        presenter = ShortClipThumbnailsPresenter(asset: asset, numberOfFramesPerCycle: numberOfFramesPerCycle)
        presenter?.delegate = self
        presenter?.removeAllFrames()
        videoLength = asset.duration.seconds
        resetData(maxTrimmingDuration: maxTrimmingDuration)
    }
    
    func resetData(maxTrimmingDuration : Double) {
        presenter?.cancelThumnailsGenerating()
        guard let presenter = presenter else {
            return
        }
        resetCollectionViewContentOffSet()
        trimmingStartTime = 0.0
        rightHandleLeadingConstraint = trimmerView?.bounds.width ?? 0.0
        leftHandleLeadingConstraint = 0.0
        validMaxTrimmingDuration = min(videoLength, maxTrimmingDuration)
        presenter.removeAllFrames()
        trimmerView?.resetHandleViewPosition()
        self.delayBetweenFrames = presenter.calculateDelayBetweenFrames(startTime: Double(trimmingStartTime), maxTrimmingDuration: Double(validMaxTrimmingDuration), numberOfFramesPerCycle: presenter.numberOfFramesPerCycle)
        presenter.setupData(delayBetweenFrames: delayBetweenFrames)
        trimmingFinishTime = validMaxTrimmingDuration
        nextDestination = min(trimmingFinishTime * 3, videoLength)
        presenter.calculateNumberOfExpectedThumbnails(videoLength: videoLength)
        presenter.addFrames(startTime: trimmingStartTime, finishTime: trimmingFinishTime)
    }
    
    private func collectionViewLayout()-> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        return layout
    }
    
    public func reloadFrames() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    
    internal func resetCollectionViewContentOffSet() {
        self.collectionView.contentOffset.x = 0.0
       
    }
    
    func updateSecondsForHandle(leadingConstraint : CGFloat)-> CGFloat {
        let leadingDistanceAsSeconds = self.getWidthToSeconds(width: leadingConstraint, delayBetweenFrames: delayBetweenFrames)
        let scrollingContentOffsetAsSeconds = self.getWidthToSeconds(width: collectionView.contentOffset.x, delayBetweenFrames: delayBetweenFrames)
        return leadingDistanceAsSeconds + scrollingContentOffsetAsSeconds
    }
    
    func getWidthToSeconds(width : CGFloat, delayBetweenFrames : CGFloat)-> CGFloat {
        guard let numberOfThumbnails = presenter?.numberOfThumbnails, let numberOfFramesPerCycle = presenter?.numberOfFramesPerCycle, numberOfThumbnails > 0 else {
            return 0.0
        }
        let perFrameWidth = self.collectionView.bounds.width / CGFloat(numberOfFramesPerCycle)
        let totalFramesWidth = perFrameWidth * CGFloat(numberOfThumbnails)
        let widthRatio = width / totalFramesWidth
        let seconds = (CGFloat(numberOfThumbnails) * delayBetweenFrames * widthRatio)
        return seconds
    }
 
    
    func scrollingOrSliderDidFinished() {
        guard let presenter = presenter else {
            return
        }
        let lowerBound = floor(max(0, self.trimmingStartTime - (presenter.delayBetweenFrames * 10)) / delayBetweenFrames)
        let upperBound = ceil(min(videoLength, self.trimmingFinishTime + (presenter.delayBetweenFrames * 10)) / presenter.delayBetweenFrames)
        let start = min(videoLength, max(0, lowerBound * presenter.delayBetweenFrames))
        let destination = max(0, min(videoLength, upperBound * presenter.delayBetweenFrames))
        presenter.addFrames(startTime: start, finishTime: destination)
    }
    
    /// get start and finish time of trimming
    public func getTrimmingStartFinishTime()-> (trimStartTime : CGFloat, trimFinishTime : CGFloat) {
        return (trimmingStartTime, trimmingFinishTime)
    }
    
    /// update positionBar with respect to player's current time
    /// - Parameters:
    ///     - cmTime: current time of AVPlayer or any Player which supports video playing
    public func updatePositionBarConstraint(cmTime : CMTime) {
        let seconds = cmTime.asDouble
        if self.trimmingFinishTime.isLess(than: seconds) {
            delegate?.didMoveToFinishPosition(startTime: self.trimmingStartTime, finishTime: self.trimmingFinishTime)
            trimmerView?.seek(to: CMTime(seconds: self.trimmingStartTime, preferredTimescale: self.timeScale), startTime: self.trimmingStartTime, finishTime: self.trimmingFinishTime, delayBetweenFrames: delayBetweenFrames)
        }
        
        else {
            trimmerView?.seek(to: cmTime, startTime: trimmingStartTime, finishTime: trimmingFinishTime, delayBetweenFrames: delayBetweenFrames)
        }
    }
}

extension ShortClipVideoTrimmerContentView : UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.numberOfThumbnails ?? 0
    }
}

extension ShortClipVideoTrimmerContentView : UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? ShortClipThumbnailsCollectionViewCell, let presenter = presenter else {
            return UICollectionViewCell()
        }
        if indexPath.item < presenter.numberOfThumbnails, let visibleFrameItem = presenter.visibleVideoFrameItemsDict[indexPath.item] {
            cell.imageView.image = visibleFrameItem.frame
        } else {
            cell.imageView.image = loadingImage
        }
        return cell
    }
    
    
}

extension ShortClipVideoTrimmerContentView : UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let presenter = presenter else {
            return CGSize(width: 50, height: collectionView.bounds.height)
        }
        return CGSize(width: self.collectionView.bounds.width / CGFloat(presenter.numberOfFramesPerCycle), height: collectionView.bounds.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension ShortClipVideoTrimmerContentView : ShortClipVideoTrimmerViewDelegate {
   
    func didLeftHandleLeadingPositionChange(leadingConstraint: CGFloat?) {
        guard let leadingConstraint = leadingConstraint else {
            return
        }
        self.leftHandleLeadingConstraint = leadingConstraint
        delegate?.didMoveToFinishPosition(startTime: trimmingStartTime, finishTime: trimmingFinishTime)
    }
    
    func didRightHandleLeadingPositionChange(leadingConstraint: CGFloat?) {
        guard let leadingConstraint = leadingConstraint else {
            return
        }
        self.rightHandleLeadingConstraint = leadingConstraint
        delegate?.didMoveToFinishPosition(startTime: trimmingStartTime, finishTime: trimmingFinishTime)
        
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let presenter = presenter else {
            return
        }
        updateTrimingStartFinishTime()
        presenter.cancelThumnailsGenerating()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollingOrSliderDidFinished()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
    
    func updateTrimingStartFinishTime() {
        trimmingStartTime = max(0.0, updateSecondsForHandle(leadingConstraint: leftHandleLeadingConstraint))
        trimmingFinishTime = min(videoLength, updateSecondsForHandle(leadingConstraint: rightHandleLeadingConstraint))
    }
}

extension ShortClipVideoTrimmerContentView : ShortClipThumbnailsPresenterDelegate {
    func reloadThumbnails() {
        reloadFrames()
    }
}

extension ShortClipVideoTrimmerContentView {
    /// update left and right Handler's width
    public func updateHandlerWidth(width : CGFloat) {
        trimmerView?.handlerWidth = width
    }
    
    /// update Knob's Width
    public func updateKnobWidth(width : CGFloat) {
        trimmerView?.knobWidth = width
    }
    
    /// update positionBar's Width
    public func updatePositionBarWidth(width : CGFloat) {
        trimmerView?.positionBarWidth = width
    }
    
  
    public func updateTrimmingAreaBorderWidth(width : CGFloat) {
        trimmerView?.borderWidth = width
    }
    
    public func handlerColor(color : UIColor) {
        trimmerView?.handlerColor = color
    }
    
    public func updateTrimmingAreaBorderColor(color : UIColor) {
        trimmerView?.borderColor = color
    }
    
    public func updateKnobColor(color : UIColor) {
        trimmerView?.knobColor = color
    }
    
    public func updatePositionBarColor(color : UIColor) {
        trimmerView?.positionBarColor = color
    }
    
    public func updateTrimmingOutsideBackgroundColor(color : UIColor) {
        trimmerView?.outsideTrimBackgroundColor = color
    }
    
    public func updateTrimmingOutsideMaskAlpha(alpha : CGFloat) {
        trimmerView?.maskAlpha = alpha
    }
}
