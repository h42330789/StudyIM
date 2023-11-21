# StudyIM

#https://juejin.cn/post/6866766361218482189
#https://www.jianshu.com/p/5727a39e8c79
#https://stackoverflow.com/questions/76590131/error-while-build-ios-app-in-xcode-sandbox-rsync-samba-13105-deny1-file-w
code > Project > Runner > Build Settings > Build Options > User Script Sandboxing -> No

OC
spec.public_header_files = ['Source/PublicHeaders/**/*.h']
spec.source_files  = "Source/**/*.{h,m,mm}"
swift
spec.source_files = 'Source/**/*.swift'
spec.dependency "xxxx"
spec.dependency "yyy"
