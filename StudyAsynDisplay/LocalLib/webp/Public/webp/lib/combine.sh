#!/bin/bash
# 合并架构
lipo -create ./arm/libsharpyuv.a ./x86/libsharpyuv.a -output ./full/libsharpyuv.a
lipo -create ./arm/libwebp.a ./x86/libwebp.a -output ./full/libwebp.a
# 查看架构  
lipo -info ./full/libsharpyuv.a
lipo -info ./full/libwebp.a