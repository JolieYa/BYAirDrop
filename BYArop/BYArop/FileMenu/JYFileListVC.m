//
//  JYFileListVC.m
//  JZMProject
//
//  Created by 龚爱荣 on 16/9/20.
//  Copyright © 2016年 金掌门科技. All rights reserved.
//

#import "JYFileListVC.h"
#import "JYFileListCell.h"
#import "JYFileModel.h"
#import "JYAudioVC.h"
#import "JYVideoVC.h"

#import "JYDataModel.h"
#import <QuickLook/QuickLook.h>

@interface JYFileListVC ()<UITableViewDataSource, UITableViewDelegate, JYFileListCellDelegate,QLPreviewControllerDataSource>
{
    JYFileModel * currentfileModel;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataAry;
@property (nonatomic, strong) NSMutableArray *selectAry;
@end

@implementation JYFileListVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    self.navigationController.navigationBar.shadowImage = [UIImage imageWithColor:JZMSeparatorColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"文件助手";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(finished)];
    
    [self downloadItem];
    [self setupView];
    [self setupData];
}

- (void)downloadItem
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"sourceData" ofType:@"plist"];

    // 2.加载数组
    NSArray *dictArray = [NSArray arrayWithContentsOfFile:plistPath];
    NSArray *modelAry = [JYDataModel modelArrayWithDictArray:dictArray];
    
    NSArray *cachesPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,  NSUserDomainMask,YES);
    NSString *ourCachesPath =[cachesPaths objectAtIndex:0];
    NSString *currentPath = [ourCachesPath stringByAppendingPathComponent:@"JZMProjectFile"];
    
    for (int i=0; i<modelAry.count; i++) {
        JYDataModel *model = modelAry[i];
        NSString *path = [[NSBundle mainBundle] pathForResource:model.name ofType:model.type];
        
        NSString *filename = [[path lastPathComponent] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"filename: %@", filename);
        NSString *filePath = [currentPath stringByAppendingPathComponent:filename];
        
        NSLog(@"filePath: %@", filePath);
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:currentPath]) {
            [fileManager createDirectoryAtPath:currentPath withIntermediateDirectories:YES attributes:nil error:nil];
            NSLog(@"fileManager: %@", fileManager);
        }
        
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isSuccess = [fm createFileAtPath:filePath contents:data attributes:nil];
        NSLog(@"isSuccess: %d", isSuccess);
    }
}

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)finished
{
    if ([self.delegate respondsToSelector:@selector(sendFile:)]) {
        [self.delegate sendFile:_selectAry];
    }
    [self cancel];
}

- (void)setupData
{
    
    _selectAry = [NSMutableArray array];
    self.dataAry = [NSMutableArray array];
    
    NSArray *cachesPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,  NSUserDomainMask,YES);
    NSString *ourCachesPath =[cachesPaths objectAtIndex:0];
    NSString *currentPath = [ourCachesPath stringByAppendingPathComponent:@"JZMProjectFile"];
    //    NSString *currentPath =[cachesPaths objectAtIndex:0];
    
    
    // 取得一个目录下得所有文件名
    NSArray *fileArys = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:currentPath error:nil];
    
    for (NSString *str in fileArys) {
        JYFileModel *model = [[JYFileModel alloc] init];
        model.name = str;
        model.filePath = [currentPath stringByAppendingPathComponent:str];
        
        NSString *extension = [model.filePath pathExtension]; // 文件扩展名
        
        if ([extension isEqualToString:@"txt"]
            || [extension isEqualToString:@"docx"]
            || [extension isEqualToString:@"doc"]
            || [extension isEqualToString:@"pdf"]
            || [extension isEqualToString:@"html"]
            || [extension isEqualToString:@"xlsx"]
            || [extension isEqualToString:@"ppt"]
            || [extension isEqualToString:@"pptx"]) {
            model.fileType = JYFileTypeDocument;
        } else if ([extension isEqualToString:@"mp4"]) {
            model.fileType = JYFileTypeVideo;
        } else if ([extension isEqualToString:@"mp3"]) {
            model.fileType = JYFileTypeAudio;
        } else if ([extension isEqualToString:@"png"] ||
                   [extension isEqualToString:@"jpg"]
                   ||[extension isEqualToString:@"jpeg"]
                   ||[extension isEqualToString:@"gif"]) {
            model.fileType = JYFileTypePicture;         }
        else {
            model.fileType = JYFileTypeDocument;         }
        
        NSDictionary *fileAttrs = [[NSFileManager defaultManager] attributesOfItemAtPath:model.filePath  error:nil];
        unsigned long long size = [fileAttrs fileSize];
        NSDate *creatDate = [fileAttrs fileCreationDate];
        
        model.size = size;
        model.creatDate = creatDate;
        [self.dataAry addObject:model];
    }
    
    // 读取某个文件
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:currentPath];
    NSLog(@"===== data: %@", data);
    
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:currentPath error:nil];
    NSLog(@"===== fattributes: %@", fattributes);
    
    NSDictionary *fat = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    NSLog(@"设备总容量：%@", [fat objectForKey:NSFileSystemSize]);
    NSLog(@"设备可用容量：%@", [fat objectForKey:NSFileSystemFreeSize]);
}

- (void)setupView
{
    UITableView *tableView = [[UITableView alloc] init];
    tableView.frame = (CGRect){0, 0, JZMWIDTH, JZMHEIGHT-64};
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:tableView];
    
    _tableView = tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JYFileListCell *cell = [JYFileListCell cellWithTableView:tableView indexPath:indexPath];
    cell.delegate = self;
    JYFileModel *model = self.dataAry[indexPath.row];
    cell.fileModel = model;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    JYFileListCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell onPick:_selectAry];
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.view.userInteractionEnabled = NO;
        JYFileModel *model = self.dataAry[indexPath.row];
        
        // 删除系统文件
        [[NSFileManager defaultManager] removeItemAtPath:model.filePath error:NULL];
        [self.dataAry removeObjectAtIndex:indexPath.row];
        
        // 更新一行
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        self.view.userInteractionEnabled = YES;
    }
}

-(void)viewDidLayoutSubviews
{
    // 重写UITableView的方法是分割线从最左侧开始
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataAry count]-1 == indexPath.row) {
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
    } else {
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 110, 0, 0)];
        }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
    }
}

#pragma mark - JYFileListCellDelegate
// 显示文件详情
- (void)showFileDetail:(UIButton *)btn
{
    // 获取'edit按钮'所在的cell
    UITableViewCell *cell = (UITableViewCell *)[[btn superview] superview];
    // 获取cell的indexPath
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    currentfileModel = self.dataAry[indexPath.row];
    
    if (currentfileModel.fileType == JYFileTypeAudio) { // 音频
        JYAudioVC *vc = [[JYAudioVC alloc] init];
        vc.fileModel =currentfileModel;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (currentfileModel.fileType== JYFileTypeVideo) { // 视频
        JYVideoVC *vc = [[JYVideoVC alloc] init];
        vc.fileModel =currentfileModel;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        [[UINavigationBar appearance] setTintColor:JZMMainColor];
        QLPreviewController*vc=[[QLPreviewController alloc]init];
        vc.dataSource=self;
        [self presentViewController:vc animated:YES completion:nil];
    }
}
#pragma mark - QLPreviewControllerDataSource
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}
- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{
    NSURL *url = [NSURL fileURLWithPath: currentfileModel.filePath];
    return url;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
