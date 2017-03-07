#
# Be sure to run `pod lib lint URLEmbeddedView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "URLEmbeddedView"
  s.version          = "0.7.0"
  s.summary          = "URLEmbeddedView is a view that automatically cache the Open Graph Protocol."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  #s.description      = <<-DESC
  #DESC

  s.homepage         = "https://github.com/marty-suzuki/URLEmbeddedView"

  s.license          = 'MIT'
  s.author           = { "Taiki Suzuki" => "s1180183@gmail.com" }
  s.source           = { :git => "https://github.com/hiranodept/URLEmbeddedView.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/marty_suzuki'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'URLEmbeddedView/*.{swift}'
  s.resources    = 'Resources/*.{pdf,xcdatamodeld}'
  #s.resource_bundles = {
  #  'Resources' => ['Resources/*.pdf']
  #}

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'CoreData', 'CoreGraphics'
  s.dependency 'MisterFusion', '~> 2.1.0'
  s.dependency 'Kanna', '~> 2.1.1'
end
