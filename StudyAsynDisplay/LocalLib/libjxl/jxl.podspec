Pod::Spec.new do |s|

    s.name         = "jxl"
    s.version      = "1.0.0"
    s.authors      = { 'Huy Nguyen' => 'hi@huynguyen.dev', 'Garrett Moon' => 'garrett@excitedpixel.com', 'Scott Goodson' => 'scottgoodson@gmail.com', 'Michael Schneider' => 'mischneider1@gmail.com', 'Adlai Holler' => 'adlai@icloud.com' }
    s.summary      = 'Smooth asynchronous user interfaces for iOS apps.'
    s.source        = { :git => "https://github.com/TextureGroup/Texture.git", :tag => s.version.to_s }
    
    s.license = 'MIT'
    s.homepage = 'http://www.example.com'
    s.requires_arc  = true
    s.ios.deployment_target = "12.0"

    s.public_header_files = ['Public/**/*.h']
    s.source_files  = 'Public/**/*.h'
    s.ios.vendored_libraries = 'Public/jxl/lib/full/*.a'
    # 查看.a的架构 lipo -info /xxx/xxx.a
    # 合并xxx.a + yyy.z 变成 zzz.a 的架构 lipo -create /xxx/xxx.a /yyy/yyy.a -output /zzz/zzz.a
    s.frameworks = "Foundation"
end
# 参考 https://github.com/TextureGroup/Texture/blob/master/Texture.podspec