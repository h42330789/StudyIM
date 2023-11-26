Pod::Spec.new do |s|
    s.name = 'CountrySelectionUI'
    s.version = '1.0.0'
    s.license = 'MIT'
    s.summary = 'Harness the power of auto layout with a simplified, chainable, and compile time safe syntax.'
    s.homepage = 'https://github.com/Markdown/Markdown'
    s.authors = { 'Robert Payne' => 'robertpayne@me.com' }
    s.social_media_url = 'http://twitter.com/robertjpayne'
    s.source = { :git => 'https://github.com/Markdown/Markdown.git', :tag => '5.6.0' }
  
    s.ios.deployment_target = '12.0'
  
    s.source_files = 'Sources/**/*.swift'

    s.dependency "SwiftSignalKit"
    s.dependency "AsyncDisplayKit"
    s.dependency "Display"
    # s.dependency "TelegramCore"
    # s.dependency "TelegramPresentationData"
    # s.dependency "TelegramStringFormatting"
    # s.dependency "SearchBarNode"
    s.dependency "AppBundle"
   
    s.libraries = 'swiftCoreGraphics'
  
    # s.xcconfig = {
    #     'LIBRARY_SEARCH_PATHS' => '$(SDKROOT)/usr/lib/swift',
    # }
  
    # s.swift_versions = ['5.0']
  end