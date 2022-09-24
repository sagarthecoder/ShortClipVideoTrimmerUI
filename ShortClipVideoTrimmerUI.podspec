#
# Be sure to run `pod lib lint ShortClipVideoTrimmerUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ShortClipVideoTrimmerUI'
  s.version          = '1.0.3'
  s.summary          = 'a smart UI designed in swift (programatically) to help you to trim a video with showing lots of frames accurately.'


  s.description      = <<-DESC
'A UIView named ShortClipVideoTrimmerContentView which helps you to select a portion of an AVAsset. It provides you with a customizable component that indicates the portion of video selected as per as the condition of maximum trimming duration you provided. It shows lots of frames which is perfectly calculated.'
                       DESC

  s.homepage         = 'https://github.com/sagarthecoder/ShortClipVideoTrimmerUI'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Sagar Chandra Das' => 'sagarthecoder@gmail.com' }
  s.source           = { :git => 'https://github.com/sagarthecoder/ShortClipVideoTrimmerUI.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/sagarthecoder'

  s.ios.deployment_target = '9.0'

  s.source_files = 'Sources/**/*.{swift}'
  
  s.swift_version = '5.0'
  s.resources = 'Photos.bundle'
  

end
