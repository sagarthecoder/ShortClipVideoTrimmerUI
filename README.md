# ShortClipVideoTrimmerUI

[![CI Status](https://img.shields.io/travis/Sagar Chandra Das/ShortClipVideoTrimmerUI.svg?style=flat)](https://travis-ci.org/Sagar Chandra Das/ShortClipVideoTrimmerUI)
[![Version](https://img.shields.io/cocoapods/v/ShortClipVideoTrimmerUI.svg?style=flat)](https://cocoapods.org/pods/ShortClipVideoTrimmerUI)
[![License](https://img.shields.io/cocoapods/l/ShortClipVideoTrimmerUI.svg?style=flat)](https://cocoapods.org/pods/ShortClipVideoTrimmerUI)
[![Platform](https://img.shields.io/cocoapods/p/ShortClipVideoTrimmerUI.svg?style=flat)](https://cocoapods.org/pods/ShortClipVideoTrimmerUI)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.
### Trimming

![](https://media.giphy.com/media/s3byxJiY06oqz9ytG1/giphy.gif)

## Requirements

- iOS 9.0+
- Interoperability with Swift 5.0+

## Installation
### CocoaPods

ShortClipVideoTrimmerUI is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ShortClipVideoTrimmerUI'
```
## Usage

:warning: _This library doesn't provide any Trimming Implementations. It has just provided the UI with video frames. You'll get trimming area (means trimming start time and trimming finish time) and then you can do anything with these informations.

### Trimming

Create an instance  (in interface builder or through code) of the `ShortClipVideoTrimmerContentView` and add it to your view hierarchy.
```
    shortClipTrimmerContentView.delegate = self // shortClipTrimmerContentView is an instance of ShortClipVideoTrimmerContentView
    shortClipTrimmerContentView.startOperation(asset: asset, maxTrimmingDuration: maxTrimmingDuration, numberOfFramesPerCycle: numberOfFramesPerCycle)
```
Here `asset` is type of AVAsset. You have to specify how much maximum trimming duration (which is `maxTrimmingDuration`) you need and how many frames should be shown per cycle (which is `numberOfFramesPerCycle`).
Then create a AVPlayer or something releated to AVPlayer. provide a timer which transferes current time of running Video. For example
```
// videoPlayer is an instance of AVPlayer
videoPlayer.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.01, preferredTimescale: 600), queue: .main) {  _ in
    
    shortClipTrimmerContentView.updatePositionBarConstraint(cmTime: videoPlayer.currentTime())
}
```
you can also customize the `ShortClipVideoTrimmerContentView` by changing it's color and width's of subcomponents.

```
shortClipTrimmerContentView.updateHandlerWidth(width : 10.0)
shortClipTrimmerContentView.updateKnobWidth(width : 3.0)
shortClipTrimmerContentView.updatePositionBarWidth(width : 4.0)
shortClipTrimmerContentView.updateTrimmingAreaBorderWidth(width : 2.0)
shortClipTrimmerContentView.handlerColor(color : UIColor.blue)
shortClipTrimmerContentView.updateTrimmingAreaBorderColor(color : UIColor.blue)
shortClipTrimmerContentView.updateKnobColor(color : UIColor.white)
shortClipTrimmerContentView.updatePositionBarColor(color : UIColor.white)
shortClipTrimmerContentView.updateTrimmingOutsideBackgroundColor(color : UIColor.white)
shortClipTrimmerContentView.updateTrimmingOutsideMaskAlpha(alpha : 0.5)   
    
```

By conforming `ShortClipVideoTrimmerContentViewDelegate` you'll get the information about when trimming start and end position is changed. For better understanding please see the example project.

## Author

Sagar Chandra Das, sagarthecoder@gmail.com

## License

ShortClipVideoTrimmerUI is available under the MIT license. See the LICENSE file for more info.
