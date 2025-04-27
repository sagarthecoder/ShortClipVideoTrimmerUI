# ShortClipVideoTrimmerUI

[![Version](https://img.shields.io/cocoapods/v/ShortClipVideoTrimmerUI.svg?style=flat)](https://cocoapods.org/pods/ShortClipVideoTrimmerUI)
[![License](https://img.shields.io/cocoapods/l/ShortClipVideoTrimmerUI.svg?style=flat)](https://cocoapods.org/pods/ShortClipVideoTrimmerUI)
[![Platform](https://img.shields.io/cocoapods/p/ShortClipVideoTrimmerUI.svg?style=flat)](https://cocoapods.org/pods/ShortClipVideoTrimmerUI)

## Example

To run the example project, clone the repo and run `pod install` from the Example directory first.

### Trimming

![Trimming](https://media.giphy.com/media/s3byxJiY06oqz9ytG1/giphy.gif)

## Requirements

- iOS 9.0+
- Swift 5.0+

## Installation

### CocoaPods

ShortClipVideoTrimmerUI is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your `Podfile`:

```ruby
pod 'ShortClipVideoTrimmerUI'
```

Then run:

```bash
pod install
```

## Usage

> ⚠️ **Note**  
> This library **only provides the UI** for video trimming with frames.  
> It does **not** perform the actual trimming.  
> You will receive the trimming area's start and end times, and can handle trimming based on that.

### Trimming Setup

Create an instance of `ShortClipVideoTrimmerContentView` (via Interface Builder or code) and add it to your view hierarchy:

```swift
shortClipTrimmerContentView.delegate = self
shortClipTrimmerContentView.startOperation(
    asset: asset,
    maxTrimmingDuration: maxTrimmingDuration,
    numberOfFramesPerCycle: numberOfFramesPerCycle
)
```

- `asset` is an `AVAsset` object.
- `maxTrimmingDuration` defines the maximum trimming length.
- `numberOfFramesPerCycle` controls how many frames are shown in one cycle.

Sync the trimmer’s position bar with video playback:

```swift
// videoPlayer is an instance of AVPlayer
videoPlayer.addPeriodicTimeObserver(
    forInterval: CMTime(seconds: 0.01, preferredTimescale: 600),
    queue: .main
) { _ in
    shortClipTrimmerContentView.updatePositionBarConstraint(cmTime: videoPlayer.currentTime())
}
```

### Customization

You can customize the appearance of `ShortClipVideoTrimmerContentView`:

```swift
shortClipTrimmerContentView.updateHandlerWidth(width: 10.0)
shortClipTrimmerContentView.updateKnobWidth(width: 3.0)
shortClipTrimmerContentView.updatePositionBarWidth(width: 4.0)
shortClipTrimmerContentView.updateTrimmingAreaBorderWidth(width: 2.0)

shortClipTrimmerContentView.handlerColor(color: .blue)
shortClipTrimmerContentView.updateTrimmingAreaBorderColor(color: .blue)
shortClipTrimmerContentView.updateKnobColor(color: .white)
shortClipTrimmerContentView.updatePositionBarColor(color: .white)
shortClipTrimmerContentView.updateTrimmingOutsideBackgroundColor(color: .white)
shortClipTrimmerContentView.updateTrimmingOutsideMaskAlpha(alpha: 0.5)
```

### Delegate

By conforming to the `ShortClipVideoTrimmerContentViewDelegate`, you can receive updates when the trimming start or end positions change.

For more information, check the example project.

## Author

**Sagar Chandra Das**  
Email: [sagarthecoder@gmail.com](mailto:sagarthecoder@gmail.com)

## License

ShortClipVideoTrimmerUI is available under the [MIT License](LICENSE).
