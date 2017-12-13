//
//  JYAudioVC.m
//  JZMProject
//
//  Created by 龚爱荣 on 16/9/22.
//  Copyright © 2016年 金掌门科技. All rights reserved.
//

#import "JYAudioVC.h"
#import <AVFoundation/AVFoundation.h>
#import "WeixinSessionActivity.h"
#import "WeixinTimelineActivity.h"
#import "JYFileModel.h"

@interface JYAudioVC ()<AVAudioPlayerDelegate,UIDocumentInteractionControllerDelegate>

@property (nonatomic,strong) AVAudioPlayer *audioPlayer;   //播放器
@property (weak, nonatomic) UIView *controlPanel;         //控制面板
@property (weak, nonatomic) UIProgressView *playProgress;  //播放进度
@property (weak, nonatomic) UIButton *playOrPause;         //播放/暂停按钮(如果tag为0认为是暂停状态，1是播放状态)
@property (weak ,nonatomic) NSTimer *timer;//进度更新定时器
@property (weak ,nonatomic) UILabel *startL;

@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;

@end

@implementation JYAudioVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.fileModel.name;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"打开" style:UIBarButtonItemStylePlain target:self action:@selector(shareOtherApp:)];
    [self setupView];
}
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)setupView
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = (CGRect){(JZMWIDTH-100)/2.0, 40, 100, 100};
    imageView.image = [UIImage imageNamed:@"input_file"];
    [self.view addSubview:imageView];
    
    UILabel *musicName = [[UILabel alloc] init];
    musicName.frame = (CGRect){13, CGRectGetMaxY(imageView.frame)+10, JZMWIDTH-26, 70};
    musicName.numberOfLines = 0;
    musicName.textAlignment = NSTextAlignmentCenter;
    musicName.text = self.fileModel.name;
    [self.view addSubview:musicName];
    
    UIView *controlPanel = [[UIView alloc] init];
    controlPanel.frame = (CGRect){0, JZMHEIGHT-80-64, JZMWIDTH, 80};
    controlPanel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self.view addSubview:controlPanel];
    self.controlPanel = controlPanel;
    
    UIButton *playOrPause = [UIButton buttonWithType:UIButtonTypeCustom];
    playOrPause.frame = (CGRect){13, 20, 40, 40};
    [playOrPause setImage:[UIImage imageNamed:@"input_file"] forState:UIControlStateNormal];
    [playOrPause addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
    playOrPause.tag = 100;
    [self.controlPanel addSubview:playOrPause];
    self.playOrPause = playOrPause;
    
    UIProgressView *playProgress = [[UIProgressView alloc] init];
    playProgress.frame = (CGRect){CGRectGetMaxX(playOrPause.frame)+13, 40, JZMWIDTH-26-CGRectGetMaxX(playOrPause.frame), 30};
    playProgress.trackTintColor = RGBAOF(0x333333, 1.0);
    playProgress.progressTintColor = JZMMainColor;
    [self.controlPanel addSubview:playProgress];
    self.playProgress = playProgress;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onChangeProgress:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.playProgress addGestureRecognizer:tap];
    
    UILabel *startL = [[UILabel alloc] init];
    startL.frame = (CGRect){CGRectGetMaxX(playOrPause.frame)+13, CGRectGetMaxY(playProgress.frame), 100, 25};
    startL.text = [NSString stringWithFormat:@"%02d:%02d", (int)self.audioPlayer.currentTime/60, ((int)self.audioPlayer.currentTime%60)];
    [self.controlPanel addSubview:startL];
    self.startL = startL;
    
    UILabel *endL = [[UILabel alloc] init];
    endL.frame = (CGRect){CGRectGetMaxX(playProgress.frame)-100, CGRectGetMaxY(playProgress.frame), 100, 25};
    endL.textAlignment = NSTextAlignmentRight;
    endL.text = [NSString stringWithFormat:@"%02d:%02d", (int)self.audioPlayer.duration/60, (int)self.audioPlayer.duration%60];
    [self.controlPanel addSubview:endL];
}

- (void)onChangeProgress:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:self.playProgress];
    float progress = (float)point.x / self.playProgress.bounds.size.width;
    self.audioPlayer.currentTime = progress * self.audioPlayer.duration;
    [self.playProgress setProgress:progress animated:YES];
    self.startL.text = [NSString stringWithFormat:@"%02d:%02d", (int)self.audioPlayer.currentTime/60, ((int)self.audioPlayer.currentTime%60)];
}

- (NSTimer *)timer{
    if (!_timer) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateProgress) userInfo:nil repeats:true];
    }
    return _timer;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.audioPlayer stop];
    [self.timer fire];
    self.timer = nil;
}

/**
 *  创建播放器
 *
 *  @return 音频播放器
 */
- (AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
        NSURL *url=[NSURL fileURLWithPath:self.fileModel.filePath];
        NSError *error=nil;
        //初始化播放器，注意这里的Url参数只能时文件路径，不支持HTTP Url
        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        //设置播放器属性
        _audioPlayer.numberOfLoops=0;//设置为0不循环
        _audioPlayer.delegate=self;
        [_audioPlayer prepareToPlay];//加载音频文件到缓存
        if(error){
            NSLog(@"初始化播放器过程发生错误,错误信息:%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}

/**
 *  播放音频
 */
- (void)play{
    if (![self.audioPlayer isPlaying]) {
        [self.audioPlayer play];
        self.timer.fireDate = [NSDate distantPast];//恢复定时器
    }
}

/**
 *  暂停播放
 */
- (void)pause{
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer pause];
        self.timer.fireDate = [NSDate distantFuture];//暂停定时器，注意不能调用invalidate方法，此方法会取消，之后无法恢复
    }
}

/**
 *  点击播放/暂停按钮
 *
 *  @param sender 播放/暂停按钮
 */
- (void)playClick:(UIButton *)sender {
    if(sender.tag == 101){
        sender.tag=100;
        [sender setImage:[UIImage imageNamed:@"input_file"] forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"input_file"] forState:UIControlStateHighlighted];
        [self pause];
    }else{
        sender.tag = 101;
        [sender setImage:[UIImage imageNamed:@"mFriendApply"] forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"mFriendApply"] forState:UIControlStateHighlighted];
        [self play];
    }
}

/**
 *  更新播放进度
 */
-(void)updateProgress{
    float progress = self.audioPlayer.currentTime /self.audioPlayer.duration;
    [self.playProgress setProgress:progress animated:YES];
    self.startL.text = [NSString stringWithFormat:@"%02d:%02d", (int)self.audioPlayer.currentTime/60, ((int)self.audioPlayer.currentTime%60)];
}

#pragma mark - 播放器代理方法
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"音乐播放完成...");
}

#pragma mark - 第三方打开

- (void)shareOtherApp:(UIBarButtonItem *)item {
    if (self.playOrPause.tag == 101) {
        [self playClick:self.playOrPause];
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
