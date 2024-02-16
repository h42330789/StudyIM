Pod::Spec.new do |s|

    s.name         = "StringTransliteration"
    s.version      = "1.0.0"
    s.authors      = { 'Huy Nguyen' => 'hi@huynguyen.dev', 'Garrett Moon' => 'garrett@excitedpixel.com', 'Scott Goodson' => 'scottgoodson@gmail.com', 'Michael Schneider' => 'mischneider1@gmail.com', 'Adlai Holler' => 'adlai@icloud.com' }
    s.summary      = 'Smooth asynchronous user interfaces for iOS apps.'
    s.source        = { :git => "https://github.com/TextureGroup/Texture.git", :tag => s.version.to_s }
    
    s.license = 'MIT'
    s.homepage = 'http://www.example.com'
    s.requires_arc  = true
    s.ios.deployment_target = "12.0"

    s.public_header_files = ['PublicHeaders/**/*.h']
    s.source_files  = ["Sources/**/*.{h,m}", "PublicHeaders/**/*.h"]
    
    s.frameworks = "Foundation"
end
# 参考 https://github.com/TextureGroup/Texture/blob/master/Texture.podspec