Pod::Spec.new do |s|

    s.name         = "libavcodec"
    s.version      = "1.0.0"
    s.authors      = { 'Huy Nguyen' => 'hi@huynguyen.dev', 'Garrett Moon' => 'garrett@excitedpixel.com', 'Scott Goodson' => 'scottgoodson@gmail.com', 'Michael Schneider' => 'mischneider1@gmail.com', 'Adlai Holler' => 'adlai@icloud.com' }
    s.summary      = 'Smooth asynchronous user interfaces for iOS apps.'
    s.source        = { :git => "https://github.com/TextureGroup/Texture.git", :tag => s.version.to_s }
    
    s.license = 'MIT'
    s.homepage = 'http://www.example.com'
    s.requires_arc  = true
    s.ios.deployment_target = "12.0"

    s.public_header_files = ['FFmpeg-iOS/include/libavcodec/**/*.h']
    s.source_files  = ['FFmpeg-iOS/include/libavcodec/**/*.h']
    s.ios.vendored_libraries = 'FFmpeg-iOS/lib/libavcodec/**/*.a'
    s.static_framework = true
    
    s.frameworks = "Foundation"
end
# 参考 https://github.com/TextureGroup/Texture/blob/master/Texture.podspec