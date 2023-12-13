Pod::Spec.new do |s|

    s.name         = "sqlcipher"
    s.version      = "1.0.0"
    s.authors      = { 'Huy Nguyen' => 'hi@huynguyen.dev', 'Garrett Moon' => 'garrett@excitedpixel.com', 'Scott Goodson' => 'scottgoodson@gmail.com', 'Michael Schneider' => 'mischneider1@gmail.com', 'Adlai Holler' => 'adlai@icloud.com' }
    s.summary      = 'Smooth asynchronous user interfaces for iOS apps.'
    s.source        = { :git => "https://github.com/TextureGroup/Texture.git", :tag => s.version.to_s }
    
    s.license = 'MIT'
    s.homepage = 'http://www.example.com'
    s.requires_arc  = true
    s.ios.deployment_target = "12.0"

    s.public_header_files = ['PublicHeaders/**/*.h']
    s.source_files  = ["PublicHeaders/**/*.h", "Sources/**/*.c"]
    sqlite_xcconfig_ios = { 'OTHER_CFLAGS' => '$(inherited) -DSQLITE_HAS_CODEC=1 -DSQLCIPHER_CRYPTO_CC=1 -DSQLITE_TEMP_STORE=2 -DSQLITE_ENABLE_FTS5 -DHAVE_USLEEP=1 -DSQLITE_DEFAULT_MEMSTATUS=0 -DSQLITE_OMIT_LOAD_EXTENSION -DSQLITE_OMIT_DECLTYPE -DSQLITE_OMIT_PROGRESS_CALLBACK -DSQLITE_OMIT_DEPRECATED -DNDEBUG=1 -DSQLITE_MAX_MMAP_SIZE=0' }
    s.ios.pod_target_xcconfig = sqlite_xcconfig_ios
    s.frameworks = "Foundation", "Security"
end
# 参考 https://github.com/TextureGroup/Texture/blob/master/Texture.podspec