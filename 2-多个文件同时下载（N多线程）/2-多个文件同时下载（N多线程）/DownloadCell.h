//
//  DownloadCell.h
//  2-多个文件同时下载（N多线程）
//
//  Created by Ljson on 15/8/13.
//  Copyright (c) 2015年 Ljson. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DownloadItem;
@interface DownloadCell : UITableViewCell

@property (nonatomic, strong) DownloadItem *downloadItem;
+ (instancetype)downloadCellWithTableView:(UITableView *)tableView;
@end
