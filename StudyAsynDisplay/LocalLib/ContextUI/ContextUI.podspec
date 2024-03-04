Pod::Spec.new do |s|
    s.name = 'ContextUI'
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
    s.dependency "TelegramCore"
    s.dependency "TelegramPresentationData"
    s.dependency "TextSelectionNode"
    s.dependency "AppBundle"
    s.dependency "AccountContext"
    s.dependency "ReactionSelectionNode"
    s.dependency "Markdown"
    s.dependency "TextFormat"
    s.dependency "TextNodeWithEntities"
    s.dependency "EntityKeyboard"
    s.dependency "UndoUI"
    s.dependency "AnimationUI"
   
    s.libraries = 'swiftCoreGraphics'
  
    # s.swift_versions = ['5.0']
  end