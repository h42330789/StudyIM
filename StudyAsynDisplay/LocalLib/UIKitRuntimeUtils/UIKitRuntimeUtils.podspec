Pod::Spec.new do |s|

    s.name         = "UIKitRuntimeUtils"
    s.version      = "1.0.0"
    s.summary      = "YTKNetwork is a high level request util based on AFNetworking."
    s.homepage     = "https://github.com/yuantiku/YTKNetwork"
    s.license      = "MIT"
    s.author       = {
                      "tangqiao" => "tangqiao@fenbi.com",
                      "lancy" => "lancy@fenbi.com",
                      "maojj" => "maojj@fenbi.com",
                      "liujl" => "liujl@fenbi.com",
                      "shangcr" => "shangcr@fenbi.com"
   }
    s.source        = { :git => "https://github.com/yuantiku/YTKNetwork.git", :tag => s.version.to_s }
    s.source_files  = "Source/**/*.{h,m}"
    s.public_header_files = 'Source/**/*.h'
    s.requires_arc  = true
    s.dependency "ObjCRuntimeUtils"
    s.dependency "AsyncDisplayKit"
  
    s.ios.deployment_target = "12.0"
    s.frameworks = "Foundation","UIKit"
end