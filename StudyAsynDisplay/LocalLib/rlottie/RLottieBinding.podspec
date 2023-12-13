Pod::Spec.new do |s|

    s.name         = "RLottieBinding"
    s.version      = "1.0.0"
    s.authors      = { 'Huy Nguyen' => 'hi@huynguyen.dev', 'Garrett Moon' => 'garrett@excitedpixel.com', 'Scott Goodson' => 'scottgoodson@gmail.com', 'Michael Schneider' => 'mischneider1@gmail.com', 'Adlai Holler' => 'adlai@icloud.com' }
    s.summary      = 'Smooth asynchronous user interfaces for iOS apps.'
    s.source        = { :git => "https://github.com/TextureGroup/Texture.git", :tag => s.version.to_s }
    
    s.license = 'MIT'
    s.homepage = 'http://www.example.com'
    s.requires_arc  = true
    s.ios.deployment_target = "12.0"

    s.public_header_files = 'PublicHeaders/**/*.h'
    s.source_files =  ['rlottie/src/**/*.cpp', 'rlottie/src/**/*.h', 'rlottie/inc/**/*.h', 'PublicHeaders/**/*.h', 'LottieInstance.mm', 'config.h']
    s.exclude_files = ["rlottie/src/vector/vdrawhelper_neon.cpp", "rlottie/src/vector/stb/**/*", "rlottie/src/lottie/rapidjson/msinttypes/**/*"]

    # s.pod_target_xcconfig = {
    #     'HEADER_SEARCH_PATHS' => '$(inherited) -Dpixman_region_selfcheck(x)=1 -DLOTTIE_DISABLE_ARM_NEON=1 -DLOTTIE_THREAD_SAFE=1 -DLOTTIE_IMAGE_MODULE_DISABLED=1'
    # }
    s.pod_target_xcconfig = {
        'HEADER_SEARCH_PATHS' => '$(inherited) -Dpixman_region_selfcheck=1 -DLOTTIE_DISABLE_ARM_NEON=1 -DLOTTIE_THREAD_SAFE=1 -DLOTTIE_IMAGE_MODULE_DISABLED=1'
    }
    s.libraries = 'c++'
end