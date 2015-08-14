//
//  DownloadUnity.h
//  多线程断点续传
//
//  Created by Ljson on 15/8/13.
//  Copyright (c) 2015年 Ljson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadUnity : NSObject
/**
 *  快速创建一个下载单元
 *
 *  @param url      下载的URL
 *  @param range    下载的范围（文件的哪一部分）
 *  @param fileName 下载后保存的文件名
 *  @param downloadingHandler 下载过程中的回调（返回新下载的数据的长度）
 *
 *  @return 快速创建的下载单元
 */
+ (instancetype)downloadUnityWithUrl:(NSString *)url range:(NSRange)range asFileName:(NSString *)fileName downloadingHandler:(void (^)(long long length))downloadingHandler;
/**
 *  快速初始化一个下载单元
 *
 *  @param url      下载的URL
 *  @param range    下载的范围（文件的哪一部分）
 *  @param fileName 下载后保存的文件名
 *  @param downloadingHandler 下载过程中的回调（返回新下载的数据的长度）
 *
 *  @return 快速初始化的下载单元
 */
- (instancetype)initWithUrl:(NSString *)url range:(NSRange)range asFileName:(NSString *)fileName downloadingHandler:(void (^)(long long length))downloadingHandler;
/**
 *  开始下载
 */
- (void)start;
/**
 *  暂停下载
 */
- (void)pause;
- (NSRange)range;
- (long long)currentLength;
@end
