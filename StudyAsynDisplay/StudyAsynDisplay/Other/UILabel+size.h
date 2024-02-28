//
//  UILabel+size.h
//  StudyAsynDisplay
//
//  Created by flow on 2/19/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (TrimmingAdditions)
typedef NS_ENUM(NSInteger, TrimmingType) {
    leading, // 开头处的空白 " ab c " -> "ab c "
    trailing, // 结尾处的空白 " ab c " -> "ab c "
    leadingAndTrailing, // 开始和结尾处的空白 " ab c " -> "ab c"
    all // 全部的空白 " ab c " -> "abc"
};
- (NSString *)trimWhitespaceWithType:(TrimmingType)type;
- (NSString *)trimWhitespaceAndNewLineWithType:(TrimmingType)type;
@end

@interface UILabel (size)
- (CGSize)calculateSize:(CGSize)size;
@end

NS_ASSUME_NONNULL_END
