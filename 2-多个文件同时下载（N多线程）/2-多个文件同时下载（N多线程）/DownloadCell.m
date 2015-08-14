//
//  DownloadCell.m
//  2-多个文件同时下载（N多线程）
//
//  Created by Ljson on 15/8/13.
//  Copyright (c) 2015年 Ljson. All rights reserved.
//

#import "DownloadCell.h"
#import "DownloadItem.h"
@interface DownloadCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UISwitch *switcher;

@end

@implementation DownloadCell
+ (instancetype)downloadCellWithTableView:(UITableView *)tableView {
    return [tableView dequeueReusableCellWithIdentifier:@"cell"];
}
- (IBAction)switcherChanged:(UISwitch *)sender {
    if (!sender.isOn) {
        [self.downloadItem pause];
    }else {
        [self.downloadItem start];
    }
    self.downloadItem.on = sender.isOn;
}
- (void)setDownloadItem:(DownloadItem *)downloadItem {
    _downloadItem = downloadItem;
    self.titleLabel.text = self.downloadItem.fileName;
    self.switcher.on = self.downloadItem.isOn;
    self.progressView.progress = self.downloadItem.progress;
}
@end
