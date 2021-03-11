#
# Be sure to run `pod lib lint AiLevelTestSFKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AiLevelTestSFKit'
  s.version          = '1.0.0'
  s.summary          = 'AiLevelTestKit SF version.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'AiLevelTestKit based on Safari browser for iOS'

  s.homepage         = 'https://github.com/jk-gna/AiLevelTestSFKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jk-gna' => 'junq.jeon@gmail.com' }
  s.source           = { :git => 'https://github.com/wonnyzone/AiLevelTestSFKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.1'

  s.source_files = 'AiLevelTestSFKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'AiLevelTestSFKit' => ['AiLevelTestSFKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
