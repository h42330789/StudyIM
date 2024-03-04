Pod::Spec.new do |s|
    s.name = 'UndoUI'
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
    s.dependency "AsyncDisplayKit"
    s.dependency "Display"
    s.dependency "TelegramCore"
    s.dependency "TelegramPresentationData"
    s.dependency "TextFormat"
    s.dependency "Markdown"
    s.dependency "RadialStatusNode"
    s.dependency "AnimationUI"
    s.dependency "AnimatedStickerNode"
    s.dependency "AppBundle"
    s.dependency "StickerResources"
    s.dependency "TelegramAnimatedStickerNode"
    s.dependency "SlotMachineAnimationNode"
    s.dependency "AvatarNode"
    s.dependency "AccountContext"
    s.dependency "ComponentFlow"
    s.dependency "AnimatedAvatarSetNode"
  
    s.libraries = 'swiftCoreGraphics'
  
  end