Pod::Spec.new do |s|
    s.name = 'Postbox'
    s.version = '1.0.0'
    s.license = 'MIT'
    s.summary = 'Harness the power of auto layout with a simplified, chainable, and compile time safe syntax.'
    s.homepage = 'https://github.com/Markdown/Markdown'
    s.authors = { 'Robert Payne' => 'robertpayne@me.com' }
    s.social_media_url = 'http://twitter.com/robertjpayne'
    s.source = { :git => 'https://github.com/Markdown/Markdown.git', :tag => '5.6.0' }
  
    s.ios.deployment_target = '12.0'
  
    s.source_files = 'Sources/**/*.swift'

    # s.dependency "Crc32",
    s.dependency "SwiftSignalKit",
    # s.dependency "sqlcipher",
    # s.dependency "MurMurHash32",
    # s.dependency "StringTransliteration",
    # s.dependency "ManagedFile",
    # s.dependency "RangeSet",
    # s.dependency "CryptoUtils",
    # s.dependency "DarwinDirStat",
  
    s.libraries = 'swiftCoreGraphics'
  
  end