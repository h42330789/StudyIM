Pod::Spec.new do |s|

    s.name         = "LegacyComponents"
    s.version      = "1.0.0"
    s.authors      = { 'Huy Nguyen' => 'hi@huynguyen.dev', 'Garrett Moon' => 'garrett@excitedpixel.com', 'Scott Goodson' => 'scottgoodson@gmail.com', 'Michael Schneider' => 'mischneider1@gmail.com', 'Adlai Holler' => 'adlai@icloud.com' }
    s.summary      = 'Smooth asynchronous user interfaces for iOS apps.'
    s.source        = { :git => "https://github.com/TextureGroup/Texture.git", :tag => s.version.to_s }
    
    s.license = 'MIT'
    s.homepage = 'http://www.example.com'
    s.requires_arc  = true
    s.ios.deployment_target = "12.0"

    s.public_header_files = ['PublicHeaders/**/*.h']
    s.source_files  = "PublicHeaders/**/*.h", "Sources/*.{h,m,mm,c,cpp}"
    # s.resources = ['LegacyImages.xcassets']
    s.resource_bundle = {'LegacyComponentsResources' => ['Resources/LegacyComponentsResources.bundle']}
    # s.resource_bundle = {'LegacyImages' => ['LegacyImages.xcassets']}
    
    s.library = 'c++'
    s.pod_target_xcconfig = {
        'CLANG_CXX_LANGUAGE_STANDARD' => 'c++11',
        'CLANG_CXX_LIBRARY' => 'libc++'
    }
    s.frameworks = "Foundation","UIKit","QuickLook","CoreMotion","Vision","PhotosUI"

    s.dependency "SSignalKit"
    s.dependency "AppBundle"
end
# 参考 https://github.com/TextureGroup/Texture/blob/master/Texture.podspec