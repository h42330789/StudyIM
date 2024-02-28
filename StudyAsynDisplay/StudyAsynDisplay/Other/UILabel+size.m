//
//  UILabel+size.m
//  StudyAsynDisplay
//
//  Created by flow on 2/19/24.
//

#import "UILabel+size.h"
#import <CoreText/CoreText.h>

@implementation NSString (TrimmingAdditions)

- (NSString *)trimWhitespaceWithType:(TrimmingType)type {
    return [self trimWithType:type characterInset:[NSCharacterSet whitespaceCharacterSet]];
}
- (NSString *)trimWhitespaceAndNewLineWithType:(TrimmingType)type {
    return [self trimWithType:type characterInset:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
- (NSString *)trimWithType:(TrimmingType)type characterInset:(NSCharacterSet *)characterSet {
    switch (type) {
        case leading:
            return [self stringByTrimmingLeadingCharactersInSet:characterSet];
        case trailing:
            return [self stringByTrimmingTrailingCharactersInSet:characterSet];
        case leadingAndTrailing:
            return [self stringByTrimmingCharactersInSet:characterSet];
        case all:
            return [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
}
- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet {
    NSUInteger location = 0;
    NSUInteger length = [self length];
    unichar charBuffer[length];
    [self getCharacters:charBuffer];

    for (NSInteger i= 0; i < length; i++) {
        if (![characterSet characterIsMember:charBuffer[i]]) {
            location = i;
            break;
        }
    }

    return [self substringWithRange:NSMakeRange(location, length - location)];
}

- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet {
    NSUInteger location = 0;
    NSUInteger length = [self length];
    unichar charBuffer[length];
    [self getCharacters:charBuffer];

    for (NSInteger i = length; i > 0; i--) {
        if (![characterSet characterIsMember:charBuffer[i - 1]]) {
            length = i;
            break;
        }
    }

    return [self substringWithRange:NSMakeRange(location, length - location)];
}

@end

@implementation UILabel (size)
- (CGSize)calculateSize:(CGSize)size
{
   
    NSAttributedString *drawString = self.attributedText;
    if (drawString == nil)
    {
        return CGSizeZero;
    }
    CFAttributedStringRef attributedStringRef = (__bridge CFAttributedStringRef)drawString;
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attributedStringRef);
    CFRange range = CFRangeMake(0, 0);
    if (self.numberOfLines > 0 && framesetter)
    {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CFArrayRef lines = CTFrameGetLines(frame);
        
        if (nil != lines && CFArrayGetCount(lines) > 0)
        {
            NSInteger lastVisibleLineIndex = MIN(self.numberOfLines, CFArrayGetCount(lines)) - 1;
            CTLineRef lastVisibleLine = CFArrayGetValueAtIndex(lines, lastVisibleLineIndex);
            
            CFRange rangeToLayout = CTLineGetStringRange(lastVisibleLine);
            range = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length);
        }
        CFRelease(frame);
        CFRelease(path);
    }
    
    CFRange fitCFRange = CFRangeMake(0, 0);
    CGSize newSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, range, NULL, size, &fitCFRange);
    if (framesetter)
    {
        CFRelease(framesetter);
    }
    CGFloat width = ceilf(newSize.width) + 1;
    CGFloat height = MIN(ceilf(newSize.height) + 1, size.height);
    
    //高度超过单行高度的1.5倍, 视为换行了, 最优宽度达到最大宽度的0.9, 则使用最大宽度
    if (height > self.font.lineHeight * 1.5 && width > size.width * 0.9) {
        width = size.width;
    }
    return CGSizeMake(width, height);
}
@end
