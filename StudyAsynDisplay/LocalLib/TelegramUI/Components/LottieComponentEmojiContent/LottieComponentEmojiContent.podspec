Pod::Spec.new do |s|
    s.name = 'LottieComponentEmojiContent'
    s.version = '1.0.0'
    s.license = 'MIT'
    s.summary = 'Harness the power of auto layout with a simplified, chainable, and compile time safe syntax.'
    s.homepage = 'https://github.com/SwiftSignalKit/SwiftSignalKit'
    s.authors = { 'Robert Payne' => 'robertpayne@me.com' }
    s.social_media_url = 'http://twitter.com/robertjpayne'
    s.source = { :git => 'https://github.com/SwiftSignalKit/SwiftSignalKit.git', :tag => '5.6.0' }
  
    s.ios.deployment_target = '12.0'
  
    s.source_files = 'Sources/**/*.swift'

    s.dependency "SwiftSignalKit"
    s.dependency "TelegramCore"
    s.dependency "LottieComponent"
    s.dependency "AccountContext"
    s.dependency "GZip"
  
    s.libraries = 'swiftCoreGraphics'
  
  end