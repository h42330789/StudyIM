#!/bin/bash
# 合并架构
lipo -create ./arm/libjpeg.a ./x86/libjpeg.a -output ./full/libjpeg.a
lipo -create ./arm/libturbojpeg.a ./x86/libturbojpeg.a -output ./full/libturbojpeg.a
# 查看架构  
lipo -info ./full/libjpeg.a
lipo -info ./full/libturbojpeg.a