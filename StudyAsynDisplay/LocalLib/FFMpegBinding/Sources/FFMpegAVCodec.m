#import <FFMpegBinding/FFMpegAVCodec.h>

#import "libavcodec/avcodec.h"

@interface FFMpegAVCodec () {
    AVCodec const *_impl;
}

@end

@implementation FFMpegAVCodec

- (instancetype)initWithImpl:(AVCodec const *)impl {
    self = [super init];
    if (self != nil) {
        _impl = impl;
    }
    return self;
}

+ (FFMpegAVCodec * _Nullable)findForId:(int)codecId {
    AVCodec const *codec = avcodec_find_decoder(codecId);
    if (codec) {
        return [[FFMpegAVCodec alloc] initWithImpl:codec];
    } else {
        return nil;
    }
}

- (void *)impl {
    return (void *)_impl;
}

@end
