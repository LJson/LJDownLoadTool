//
//  DownloadTool.h
//  多线程断点续传
//
//  Created by Ljson on 15/8/13.
//  Copyright (c) 2015年 Ljson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
@interface DownloadTool : NSObject
/**
 *  快速创建一个下载器
 *
 *  @param url      下载的地址
 *  @param fileName 下载之后保存的文件名
 *
 *  @return 返回创建的下载器
 */
+ (instancetype)downloadToolWithUrl:(NSString *)url asFileName:(NSString *)fileName downloadingHandler:(void (^)(CGFloat progress))downloadingHandler;
/**
 *  快速初始化一个下载器
 *
 *  @param url      下载的地址
 *  @param fileName 下载之后保存的文件名
 *  @param downloadingHandler 下载过程中的回调，传递下载进度
 *
 *  @return 返回初始化好的下载器
 */
- (instancetype)initWithWithUrl:(NSString *)url asFileName:(NSString *)fileName downloadingHandler:(void (^)(CGFloat progress))downloadingHandler;
/**
 *  开始下载
 */
- (void)start;
/**
 *  zantin下载
 */
- (void)pause;
@end
