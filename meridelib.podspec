#
# Be sure to run `pod lib lint meridelib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'meridelib'
  s.version          = '0.1.0'
  s.summary          = 'first pod create'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    first library create
  DESC

  s.homepage         = 'https://github.com/Jignesh1805/meridelib'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jignesh1805' => 'jigneshrathod1805@gmail.com' }
  s.source           = { :git => 'https://github.com/Jignesh1805/meridelib.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'Classes/**/*'
  #s.resources = "Classes/UIView/*"
  #s.resources = "Classes/UIView/**/*.{png,jpeg,jpg,storyboard,xib}"
  #s.resources = "Classes/UIView/PlayerProgressView.xib"


  # s.resource_bundles = {
  #   'meridelib' => ['meridelib/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
   s.frameworks = 'UIKit'
   s.dependency 'GoogleAds-IMA-iOS-SDK', '~> 3.7'
end
