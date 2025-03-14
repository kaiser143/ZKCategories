#
# Be sure to run `pod lib lint ZKCategories.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZKCategories'
  s.version          = "0.4.13"
  s.summary          = 'A short description of ZKCategories.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/kaiser143/ZKCategories'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kaiser' => 'deyang143@126.com' }
  s.source           = { :git => 'https://github.com/kaiser143/ZKCategories.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.requires_arc = true
  s.ios.deployment_target = '9.0'
  s.default_subspec = 'Core'

  s.subspec 'Core' do |ss|
      ss.source_files = 'ZKCategories/Classes/**/*'
  end
  
  #  KVO 防闪退
  s.subspec 'ZKKVOSAFE' do |ss|
      ss.dependency 'ZKCategories/Core'
      ss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'KVOSAFE=1'}
  end
  
  # s.resource_bundles = {
  #   'ZKCategories' => ['ZKCategories/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

  s.libraries = 'z'
end
