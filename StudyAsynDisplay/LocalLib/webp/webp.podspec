Pod::Spec.new do |s|

    s.name         = "webp"
    s.version      = "1.0.0"
    s.authors      = { 'Huy Nguyen' => 'hi@huynguyen.dev', 'Garrett Moon' => 'garrett@excitedpixel.com', 'Scott Goodson' => 'scottgoodson@gmail.com', 'Michael Schneider' => 'mischneider1@gmail.com', 'Adlai Holler' => 'adlai@icloud.com' }
    s.summary      = 'Smooth asynchronous user interfaces for iOS apps.'
    s.source        = { :git => "https://github.com/TextureGroup/Texture.git", :tag => s.version.to_s }
    
    s.license = 'MIT'
    s.homepage = 'http://www.example.com'
    s.requires_arc  = true
    s.ios.deployment_target = "12.0"
    # 使用编译后的内容
    s.public_header_files = ['Public/**/*.h']
    s.source_files  = ["Public/**/*.h"]
    # s.ios.vendored_libraries = 'Public/webp/lib/x86/*.a'
    s.ios.vendored_libraries = 'Public/webp/lib/full/*.a'
    s.static_framework = true
    # s.ios.vendored_frameworks = 'StaticLibraryFolder/StaticLibrary.framework'

    
    s.frameworks = "Foundation", "UIKit"
end
# 参考 https://github.com/TextureGroup/Texture/blob/master/Texture.podspec