Pod::Spec.new do |s|
    s.name = 'ItemListUI'
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
    s.dependency "TelegramPresentationData"
    s.dependency "MergeLists"
    s.dependency "TextFormat"
    s.dependency "Markdown"
    s.dependency "ProgressNavigationButtonNode"
    s.dependency "SwitchNode"
    s.dependency "AnimatedStickerNode"
    s.dependency "TelegramAnimatedStickerNode"
    s.dependency "CheckNode"
    s.dependency "SegmentedControlNode"
#    s.dependency "AccountContext"
    s.dependency "AnimationUI"
    s.dependency "ShimmerEffect"
    s.dependency "ManagedAnimationNode"
    s.dependency "AvatarNode"
    s.dependency "TelegramCore"
  
    s.libraries = 'swiftCoreGraphics'
  end
