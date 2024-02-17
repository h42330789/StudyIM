#!/bin/bash
# 合并架构
lipo -create ./arm/libbrotlicommon.a ./x86/libbrotlicommon.a -output ./full/libbrotlicommon.a
lipo -create ./arm/libbrotlidec.a ./x86/libbrotlidec.a -output ./full/libbrotlidec.a
lipo -create ./arm/libbrotlienc.a ./x86/libbrotlienc.a -output ./full/libbrotlienc.a
lipo -create ./arm/libhwy.a ./x86/libhwy.a -output ./full/libhwy.a
lipo -create ./arm/libjxl.a ./x86/libjxl.a -output ./full/libjxl.a
# 查看架构  
lipo -info ./full/libbrotlicommon.a
lipo -info ./full/libbrotlidec.a
lipo -info ./full/libbrotlienc.a
lipo -info ./full/libhwy.a
lipo -info ./full/libjxl.a