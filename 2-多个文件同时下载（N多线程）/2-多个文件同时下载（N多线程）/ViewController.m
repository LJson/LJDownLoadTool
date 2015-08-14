//
//  ViewController.m
//  2-多个文件同时下载（N多线程）
//
//  Created by Ljson on 15/8/13.
//  Copyright (c) 2015年 Ljson. All rights reserved.
//

#import "ViewController.h"
#import "DownloadItem.h"
#import "DownloadCell.h"
@interface ViewController ()
@property (nonatomic, strong) NSArray *downloadItems;
@end

@implementation ViewController
- (NSArray *)downloadItems
{
    if (!_downloadItems) {
        NSMutableArray *arrayM = [NSMutableArray array];
        for (int i = 1; i < 17; i ++) {
            DownloadItem *item = [[DownloadItem alloc]init];
            item.url = [NSString stringWithFormat:@"http://120.25.226.186:32812/resources/videos/minion_%02d.mp4",i];
            item.indexPath = [NSIndexPath indexPathForRow:i - 1 inSection:0];
            item.downloadHandler = ^(NSIndexPath *indexPath) {
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            };
            item.complicationHandler = ^ (NSIndexPath *indexPath){
                [self deleteItemAtIndexPath:indexPath];
                NSLog(@"删除了第 %zd 行的数据",indexPath.row);
            };
            [arrayM addObject:item];
        }
        _downloadItems = arrayM;
    }
    return _downloadItems;
}
- (void)deleteItemAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *arrayM = [NSMutableArray arrayWithArray:self.downloadItems];
    [arrayM removeObjectAtIndex:indexPath.row];
    self.downloadItems = arrayM;
    [self.tableView reloadData];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.downloadItems.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadCell *cell = [DownloadCell downloadCellWithTableView:tableView];
    cell.downloadItem = self.downloadItems[indexPath.row];
    //更新item的indexPath
    cell.downloadItem.indexPath = indexPath;
    return cell;
}
@end
