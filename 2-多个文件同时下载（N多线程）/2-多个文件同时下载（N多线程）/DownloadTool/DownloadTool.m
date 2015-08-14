//
//  DownloadTool.m
//  多线程断点续传
//
//  Created by Ljson on 15/8/13.
//  Copyright (c) 2015年 Ljson. All rights reserved.
//

#import "DownloadTool.h"
#import "NSString+NJ.h"
#import "DownloadUnity.h"
#import <UIKit/UIKit.h>
@interface DownloadTool ()<NSURLConnectionDataDelegate>
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, assign) long long totalLength;
@property (nonatomic, assign) long long currentLength;
@property (nonatomic, strong) NSArray *downloadUnities;
@property (nonatomic, strong) NSMutableDictionary *resumeData;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, copy) void (^downloadingHandler)(CGFloat);
@end

@implementation DownloadTool
- (NSMutableDictionary *)resumeData
{
    if (!_resumeData) {
        _resumeData = [NSMutableDictionary dictionary];
    }
    return _resumeData;
}

+ (instancetype)downloadToolWithUrl:(NSString *)url asFileName:(NSString *)fileName downloadingHandler:(void (^)(CGFloat))downloadingHandler {
    DownloadTool *tool = [[self alloc]initWithWithUrl:url asFileName:fileName downloadingHandler:downloadingHandler];
    return tool;
}
- (instancetype)initWithWithUrl:(NSString *)url asFileName:(NSString *)fileName downloadingHandler:(void (^)(CGFloat))downloadingHandler {
    if (self = [super init]) {
        self.url = url;
        self.fileName = fileName;
        self.downloadingHandler = downloadingHandler;
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(wiilExit:) name:UIApplicationWillTerminateNotification object:nil];
    return self;
}
- (void)start {
    if (!self.downloadUnities.count) {
        [self readResumeData];
    }
    if (!self.downloadUnities.count) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
        request.HTTPMethod = @"HEAD";
        //忽略缓存，以免下载不成功（因为我已经做了缓存功能）
        request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        _connection = [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:YES];
    }else {
        for (DownloadUnity *unity in self.downloadUnities) {
            [unity start];
        }
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
        self.totalLength = response.expectedContentLength;
        NSLog(@"总共的长度：%lld",self.totalLength);
        NSString *filePath = [self.fileName cacheDir];
        //在caches目录创建文件，用来保存下载的文件
        [[NSFileManager defaultManager]createFileAtPath:filePath contents:nil attributes:nil];
        [self createDownloadUnities];
}
- (void)createDownloadUnities {
        //如果没有创建下载单元，就创建下载单元
        long long perLineLength = 2 * 1024 * 1024;
        int lineCount = ceilf(1.0 * self.totalLength / perLineLength);
        NSMutableArray *arrayM = [NSMutableArray array];
        for (int i = 0; i < lineCount; i ++ ) {
            NSUInteger loc = i * perLineLength;
            NSUInteger len = perLineLength;
            NSRange range = NSMakeRange(loc, len);
            DownloadUnity *unity = [DownloadUnity downloadUnityWithUrl:self.url range:range asFileName:self.fileName downloadingHandler:^(long long length) {
                self.currentLength += length;
                if (self.downloadingHandler) {
                    CGFloat progress = 1.0 * self.currentLength / self.totalLength;
                    if (progress >= 1.0) {
                        progress = 1.0;
                    }
                    self.downloadingHandler(progress);
                    if (progress >= 1.0) {
                        [self removeResumeDataFile];
                    }
                }
            }];
            [arrayM addObject:unity];
        }
        self.downloadUnities = arrayM;

    for (DownloadUnity *unity in self.downloadUnities) {
        [unity start];
    }
}
- (void)pause {
    for (DownloadUnity *unity in self.downloadUnities) {
        [unity pause];
    }
    [self writeResumeData];
}
//如果有必要，保存当前的下载信息
- (void)writeResumeData {
    self.resumeData[@"fileName"] = self.fileName;
    self.resumeData[@"url"] = self.url;
    self.resumeData[@"totalLength"] = @(self.totalLength);
    self.resumeData[@"currentLength"] = @(self.currentLength);
    NSMutableArray *downloadUnitiesArrayM = [NSMutableArray array];
    for (int i = 0; i < (int)self.downloadUnities.count; i ++) {
        DownloadUnity *unity = self.downloadUnities[i];
        //计算当前的下载单元剩下的内容，以便下一次下载
        NSUInteger loc = unity.range.location + unity.currentLength;
        NSUInteger len = unity.range.length - unity.currentLength;
        NSRange range = NSMakeRange(loc, len);
        NSDictionary *tempDict = @{@"rangeloc":@(range.location),@"rangelen":@(range.length)};
        [downloadUnitiesArrayM addObject:tempDict];
    }
    self.resumeData[@"downloadUnities"] = downloadUnitiesArrayM;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict = self.resumeData;
    [dict writeToFile:[[NSString stringWithFormat:@"%@.resumeData",self.fileName] cacheDir] atomically:YES];
}
//读取上次的下载信息，看是否要继续下载
- (void)readResumeData {
    self.resumeData = [NSMutableDictionary dictionaryWithContentsOfFile:[[NSString stringWithFormat:@"%@.resumeData",self.fileName] cacheDir]];
    if (!self.resumeData[@"downloadUnities"]) {
        return;
    }
    self.fileName = self.resumeData[@"fileName"];
    self.url = self.resumeData[@"url"];
    self.totalLength = [self.resumeData[@"totalLength"] integerValue];
    self.currentLength = [self.resumeData[@"currentLength"] integerValue];
    
    NSDictionary *downloadUnitiesDict = self.resumeData[@"downloadUnities"];
    NSMutableArray *arrayM = [NSMutableArray array];
    for (NSDictionary *dict in downloadUnitiesDict) {
        //根据保存的内容创建下载器！！！
        NSLog(@"readDict:%@",dict);
        NSUInteger loc = [dict[@"rangeloc"] integerValue];
        NSUInteger len = [dict[@"rangelen"] integerValue];
        NSRange range = NSMakeRange(loc, len);
        DownloadUnity *unity = [DownloadUnity downloadUnityWithUrl:self.url range:range asFileName:self.fileName downloadingHandler:^(long long length) {
            self.currentLength += length;
            if (self.downloadingHandler) {
                CGFloat progress = 1.0 * self.currentLength / self.totalLength;
                if (progress >= 1.0) {
                    progress = 1.0;
                }
                if (progress >= 1.0) {
                    [self removeResumeDataFile];
                }
                self.downloadingHandler(progress);
            }
        }];
        [arrayM addObject:unity];
    }
    self.downloadUnities = arrayM;
}
//删除缓存信息文件
- (void)removeResumeDataFile {
    NSLog(@"filename:%@",self.fileName);
    [[NSFileManager defaultManager] removeItemAtPath:[[NSString stringWithFormat:@"%@.resumeData",self.fileName] cacheDir] error:nil];
}
- (void)wiilExit:(NSNotification *)note {
   NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.fileName cacheDir] error:nil];
    //如果已经下载完毕，就不用在退出的时候保存下载信息
    if (self.currentLength >= [dict[@"NSFileSize"] integerValue]) {
        return;
    }
    [self writeResumeData];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
