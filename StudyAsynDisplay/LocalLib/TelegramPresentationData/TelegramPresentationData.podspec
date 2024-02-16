Pod::Spec.new do |s|
    s.name = 'TelegramPresentationData'
    s.version = '1.0.0'
    s.license = 'MIT'
    s.summary = 'Harness the power of auto layout with a simplified, chainable, and compile time safe syntax.'
    s.homepage = 'https://github.com/Markdown/Markdown'
    s.authors = { 'Robert Payne' => 'robertpayne@me.com' }
    s.social_media_url = 'http://twitter.com/robertjpayne'
    s.source = { :git => 'https://github.com/Markdown/Markdown.git', :tag => '5.6.0' }
  
    s.ios.deployment_target = '12.0'
  
    s.source_files = 'Source/**/*.swift'
  
    
    
    # s.dependency "TelegramCore"
    # s.dependency "Postbox"
    s.dependency "Display"
    s.dependency "SwiftSignalKit"
    # s.dependency "TelegramUIPreferences"
    # s.dependency "MediaResources"
    s.dependency "AppBundle"
    # s.dependency "StringPluralization"
    # s.dependency "Sunrise"
    # s.dependency "TinyThumbnail"
    # s.dependency "FastBlur"
    # s.dependency "PresentationStrings"
  
    s.libraries = 'swiftCoreGraphics'
  end