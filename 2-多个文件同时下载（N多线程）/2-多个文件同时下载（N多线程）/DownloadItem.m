//
//  DownloadItem.m
//  2-多个文件同时下载（N多线程）
//
//  Created by Ljson on 15/8/14.
//  Copyright (c) 2015年 Ljson. All rights reserved.
//

#import "DownloadItem.h"
#import "DownloadTool.h"
#import <UIKit/UIKit.h>
@interface DownloadItem ()
@property (nonatomic, strong) DownloadTool *downloadTool;
@end

@implementation DownloadItem
- (void)setUrl:(NSString *)url {
    _url = [url copy];
    self.downloadTool = [DownloadTool downloadToolWithUrl:url asFileName:url.lastPathComponent downloadingHandler:^(CGFloat progress) {
        self.progress = progress;
        NSLog(@"%zd-->%f",self.indexPath.row,self.progress);
        if (self.downloadHandler) {
            self.downloadHandler(self.indexPath);
        }
        if (progress >= 1.0) {
            if (self.complicationHandler) {
                NSLog(@"第%zd行数据下载完毕",self.indexPath.row);
                self.complicationHandler(self.indexPath);
                //避免执行多次，误删数据
                self.complicationHandler = nil;
            }
        }
    }];
}
- (NSString *)fileName {
    return self.url.lastPathComponent;
}
- (void)start {
    [self.downloadTool start];
}
- (void)pause {
    [self.downloadTool pause];
}
@end
