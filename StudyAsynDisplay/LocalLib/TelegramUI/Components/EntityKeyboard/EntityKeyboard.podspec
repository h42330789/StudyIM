Pod::Spec.new do |s|
    s.name = 'EntityKeyboard'
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
    s.dependency "Display"
    s.dependency "ComponentFlow"
    s.dependency "PagerComponent"
    s.dependency "BlurredBackgroundComponent"
    s.dependency "ComponentDisplayAdapters"
    s.dependency "BundleIconComponent"
    s.dependency "TelegramPresentationData"
    s.dependency "TelegramCore"
    s.dependency "Postbox"
    s.dependency "AnimatedStickerNode"
    s.dependency "TelegramAnimatedStickerNode"
    s.dependency "YuvConversion"
    s.dependency "AccountContext"
    s.dependency "AnimationCache"
    s.dependency "LottieAnimationCache"
    s.dependency "VideoAnimationCache"
    s.dependency "MultiAnimationRenderer"
    s.dependency "EmojiTextAttachmentView"
    s.dependency "EmojiStatusComponent"
    s.dependency "LottieComponent"
    s.dependency "LottieComponentEmojiContent"
    s.dependency "SoftwareVideo"
    s.dependency "ShimmerEffect"
    s.dependency "PhotoResources"
    s.dependency "StickerResources"
    s.dependency "AppBundle"
    s.dependency "UndoUI"
    s.dependency "MultilineTextComponent"
    s.dependency "SolidRoundedButtonComponent"
    s.dependency "LottieAnimationComponent"
    s.dependency "LocalizedPeerData"
    s.dependency "TelegramNotices"
    s.dependency "GZip"
    s.dependency "RLottieBinding"
    s.dependency "Lottie"
    s.dependency "GenerateStickerPlaceholderImage"
  
    s.libraries = 'swiftCoreGraphics'
  
  end