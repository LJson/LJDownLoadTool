//
//  DownloadUnity.m
//  多线程断点续传
//
//  Created by Ljson on 15/8/13.
//  Copyright (c) 2015年 Ljson. All rights reserved.
//

#import "DownloadUnity.h"
#import "NSString+NJ.h"
@interface DownloadUnity ()<NSURLConnectionDataDelegate>
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *fileNme;
@property (nonatomic, assign) NSRange range;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, assign) long long currentLength;
@property (nonatomic, strong) NSFileHandle *fileHnadle;
@property (nonatomic, copy) void(^downloadingHandler)(long long);
@end

@implementation DownloadUnity
- (NSFileHandle *)fileHnadle
{
//    if (!_fileHnadle) {
        _fileHnadle = [NSFileHandle fileHandleForWritingAtPath:[self.fileNme cacheDir]];
//    }
    return _fileHnadle;
}

+ (instancetype)downloadUnityWithUrl:(NSString *)url range:(NSRange)range asFileName:(NSString *)fileName downloadingHandler:(void (^)(long long))downloadingHandler {
    DownloadUnity *unity = [[self alloc]initWithUrl:url range:range asFileName:fileName downloadingHandler:downloadingHandler];
    return unity;
}
- (instancetype)initWithUrl:(NSString *)url range:(NSRange)range asFileName:(NSString *)fileName downloadingHandler:(void (^)(long long))downloadingHandler {
    if (self = [super init]) {
        self.url = url;
        self.range = range;
        self.fileNme = fileName;
        self.downloadingHandler = downloadingHandler;
    }
    return self;
}
- (void)start {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    long long start = self.range.location + self.currentLength;
    long long end = self.range.location + self.range.length - 1;
    NSString *rangeStr = [NSString stringWithFormat:@"bytes=%lld-%lld",start,end];
    NSLog(@"开启下载单元：%lld<-->%lld",start,end);
    [request setValue:rangeStr forHTTPHeaderField:@"Range"];
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:YES];
    self.connection = connection;
}
- (void)pause {
    [self.connection cancel];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    long long fileOffset = self.range.location + self.currentLength;
    NSLog(@"fileoffset:%lld",fileOffset);
    @try {
        [self.fileHnadle seekToFileOffset:fileOffset];
        [self.fileHnadle writeData:data];
    }
    @catch (NSException *exception) {
        NSLog(@"fileHnadle-->%@",self.fileHnadle);
        [NSException raise:@"崩了！" format:@"你特么的一次下载这么多，还瞎滚，当然会崩啊！"];
    }
    @finally {
    }
    self.currentLength += data.length;
    if (self.downloadingHandler) {
        self.downloadingHandler(data.length);
    }
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.fileHnadle closeFile];
    NSLog(@"下载完了");
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error  {
    [self.fileHnadle closeFile];
    NSLog(@"下载出错了");
}
- (NSRange)range {
    return _range;
}

- (long long)currentLength {
    return _currentLength;
}
@end
