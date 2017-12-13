//
//  ViewController.m
//  BYArop
//
//  Created by admin on 2017/11/3.
//  Copyright © 2017年 XHWL. All rights reserved.
//

#import "ViewController.h"
#import "JYFileListVC.h"
#import "JYFileModel.h"
#import <QuickLook/QuickLook.h>

@interface ViewController ()<JYFileListVCDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    JYFileListVC *vc = [[JYFileListVC alloc] init];
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}


- (JYFileType)fileTypeForExtension:(NSString *)extension
{
    if ([extension isEqualToString:@"txt"]
        || [extension isEqualToString:@"docx"]
        || [extension isEqualToString:@"doc"]
        || [extension isEqualToString:@"pdf"]
        || [extension isEqualToString:@"html"]
        || [extension isEqualToString:@"xlsx"]
        || [extension isEqualToString:@"ppt"]
        || [extension isEqualToString:@"pptx"]) {
        return JYFileTypeDocument;
    } else if ([extension isEqualToString:@"mp4"]) {
        return JYFileTypeVideo;
    } else if ([extension isEqualToString:@"mp3"]) {
        return JYFileTypeAudio;
    } else if ([extension isEqualToString:@"png"] ||
               [extension isEqualToString:@"jpg"]
               ||[extension isEqualToString:@"jpeg"]
               ||[extension isEqualToString:@"gif"]) {
        return JYFileTypePicture;
    } else {
        return JYFileTypeNone;
    }
}

- (void)sendFile:(NSArray *)selectAry
{
    NSLog(@"发送文件");
//    for (JYFileModel *model in selectAry) {
//        NSError *err = nil;
//        NSData* data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:model.filePath] options:NSDataReadingMappedIfSafe error:&err];
//        //文件最大不超过28MB
//        if(data.length < 28 * 1024 * 1024) {
//            IMAMsg *msg = [IMAMsg msgWithFilePath:[NSURL fileURLWithPath:model.filePath]];
//            [self sendMsg:msg];
//        } else {
////            [MBProgressHUD showError:@"发送的文件过大"];
//        }
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
