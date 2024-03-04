Pod::Spec.new do |s|
    s.name = 'PresentationDataUtils'
    s.version = '1.0.0'
    s.license = 'MIT'
    s.summary = 'Harness the power of auto layout with a simplified, chainable, and compile time safe syntax.'
    s.homepage = 'https://github.com/Markdown/Markdown'
    s.authors = { 'Robert Payne' => 'robertpayne@me.com' }
    s.social_media_url = 'http://twitter.com/robertjpayne'
    s.source = { :git => 'https://github.com/Markdown/Markdown.git', :tag => '5.6.0' }
  
    s.ios.deployment_target = '12.0'
  
    s.source_files = 'Sources/**/*.swift'
    
    s.dependency "Display"
    s.dependency "SwiftSignalKit"
    s.dependency "AccountContext"
    s.dependency "TelegramPresentationData"
    s.dependency "AlertUI"
    s.dependency "ItemListUI"
    s.dependency "SolidRoundedButtonNode"
    s.dependency "OverlayStatusController"
    s.dependency "UrlWhitelist"
  
    s.libraries = 'swiftCoreGraphics'
  end