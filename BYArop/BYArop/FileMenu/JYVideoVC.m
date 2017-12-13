//
//  JYVideoVC.m
//  JZMProject
//
//  Created by 龚爱荣 on 16/9/23.
//  Copyright © 2016年 金掌门科技. All rights reserved.
//

#import "JYVideoVC.h"
//#import "WeixinSessionActivity.h"
//#import "WeixinTimelineActivity.h"
#import <MediaPlayer/MediaPlayer.h>
#import "JYFileModel.h"
@interface JYVideoVC ()<UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic,strong) MPMoviePlayerController *moviePlayer;//视频播放控制器
@end

@implementation JYVideoVC

#pragma mark - 控制器视图方法
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    
    // 添加通知
    [self addNotification];
    
    //获取缩略图
    [self thumbnailImageRequest];
}

/**
 *  获取视频缩略图
 */
-(void)thumbnailImageRequest{
    //获取13.0s、21.5s的缩略图
    [self.moviePlayer requestThumbnailImagesAtTimes:@[@13.0,@21.5] timeOption:MPMovieTimeOptionNearestKeyFrame];
}


- (void)setupView
{
    self.title = self.fileModel.name;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"打开" style:UIBarButtonItemStylePlain target:self action:@selector(shareOtherApp:)];
    
    [self.moviePlayer stop];
    
    // 播放
//    [self.moviePlayer play];
}

- (void)dealloc{
    //移除所有通知监控
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 私有方法
/**
 *  取得本地文件路径
 *
 *  @return 文件路径
 */
-(NSURL *)getFileUrl{
    NSURL *url=[NSURL fileURLWithPath:self.fileModel.filePath];
    return url;
}

/**
 *  取得网络文件路径
 *
 *  @return 文件路径
 */
-(NSURL *)getNetworkUrl{
    NSString *urlStr=@"http://192.168.1.161/The New Look of OS X Yosemite.mp4";
    urlStr=[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    return url;
}

/**
 *  创建媒体播放控制器
 *
 *  @return 媒体播放控制器
 */
-(MPMoviePlayerController *)moviePlayer{
    if (!_moviePlayer) {
//        NSURL *url=[self getNetworkUrl];
        NSURL *url = [self getFileUrl];
        _moviePlayer = [[MPMoviePlayerController alloc]initWithContentURL:url];
        _moviePlayer.view.frame = self.view.bounds;
        _moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _moviePlayer.shouldAutoplay = NO;
        [self.view addSubview:_moviePlayer.view];
    }
    return _moviePlayer;
}

/**
 *  添加通知监控媒体播放控制器状态
 */
-(void)addNotification{
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(mediaPlayerPlaybackStateChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.moviePlayer];
    [notificationCenter addObserver:self selector:@selector(mediaPlayerPlaybackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
     [notificationCenter addObserver:self selector:@selector(mediaPlayerThumbnailRequestFinished:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:self.moviePlayer];
}

/**
 *  播放状态改变，注意播放完成时的状态是暂停
 *
 *  @param notification 通知对象
 */
-(void)mediaPlayerPlaybackStateChange:(NSNotification *)notification{
    switch (self.moviePlayer.playbackState) {
        case MPMoviePlaybackStatePlaying:
            NSLog(@"正在播放..."); // 播放
//            [self.moviePlayer pause];
            break;
        case MPMoviePlaybackStatePaused:
            NSLog(@"暂停播放.");  // 播放
//            [self.moviePlayer pause];
            break;
        case MPMoviePlaybackStateStopped:
            NSLog(@"停止播放.");  // 播放
//            [self.moviePlayer stop];
            break;
        default:
            NSLog(@"播放状态:%li",(long)self.moviePlayer.playbackState);
            // 播放
//            [self.moviePlayer stop];
            break;
    }
}

/**
 *  播放完成
 *
 *  @param notification 通知对象
 */
-(void)mediaPlayerPlaybackFinished:(NSNotification *)notification{
    NSLog(@"播放完成.%li",(long)self.moviePlayer.playbackState);
}

/**
 *  缩略图请求完成,此方法每次截图成功都会调用一次
 *
 *  @param notification 通知对象
 */
-(void)mediaPlayerThumbnailRequestFinished:(NSNotification *)notification{
    NSLog(@"视频截图完成.");
    UIImage *image=notification.userInfo[MPMoviePlayerThumbnailImageKey];
    //保存图片到相册(首次调用会请求用户获得访问相册权限)
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

#pragma mark - 第三方打开

- (void)shareOtherApp:(UIBarButtonItem *)item {
    if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [self.moviePlayer pause];
    }
     NSURL *url = [NSURL fileURLWithPath:self.fileModel.name];
    [self addThirdAPPOpenFile:url];
}

//第三方app打开文件
- (void)addThirdAPPOpenFile:(NSURL*)filePath
{
    _documentInteractionController = [UIDocumentInteractionController
                                      interactionControllerWithURL:filePath];
    [_documentInteractionController setDelegate:self];
    
    [_documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
}
@end
