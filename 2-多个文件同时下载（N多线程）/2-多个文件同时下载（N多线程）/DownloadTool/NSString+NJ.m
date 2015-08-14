//
//  NSString+NJ.m
//  09-多图片下载
//
//  Created by apple on 15/8/6.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "NSString+NJ.h"

@implementation NSString (NJ)

- (instancetype)cacheDir
{
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return [dir stringByAppendingPathComponent:[self lastPathComponent]];
}
- (instancetype)docDir
{
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [dir stringByAppendingPathComponent:[self lastPathComponent]];
}

- (instancetype)tmpDir
{
    NSString *dir = NSTemporaryDirectory();
    return [dir stringByAppendingPathComponent:[self lastPathComponent]];
}
@end
