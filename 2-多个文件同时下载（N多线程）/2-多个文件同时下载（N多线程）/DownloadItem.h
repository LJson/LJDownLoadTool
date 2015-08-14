//
//  DownloadItem.h
//  2-多个文件同时下载（N多线程）
//
//  Created by Ljson on 15/8/14.
//  Copyright (c) 2015年 Ljson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
@interface DownloadItem : NSObject
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign, getter=isOn) BOOL on;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, copy) void (^downloadHandler)(NSIndexPath *);
@property (nonatomic, copy) void (^complicationHandler)(NSIndexPath *);
- (void)start;
- (void)pause;
@end
