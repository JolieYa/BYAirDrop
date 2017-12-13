//
//  JYFileModel.h
//  JZMProject
//
//  Created by 龚爱荣 on 16/9/22.
//  Copyright © 2016年 金掌门科技. All rights reserved.
//

#import <Foundation/Foundation.h>



//enum{
//    UIViewAnimationTransitionNone,
//    UIViewAnimationTransitionFlipFromLeft,
//    UIViewAnimationTransitionFlipFromRight,
//    UIViewAnimationTransitionCurlUp,
//    UIViewAnimationTransitionCurlDown,
//} UIViewAnimationTransition;

// 文件类型
typedef NS_ENUM (NSInteger, JYFileType) {
    JYFileTypeNone,         // 默认所有类型
    JYFileTypeDocument,     // 文档
    JYFileTypeAudio,        // 音频
    JYFileTypeVideo,        // 视频
    JYFileTypePicture       // 图片
};

@interface JYFileModel : NSObject

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) unsigned long long size;
@property (nonatomic, strong) NSDate *creatDate;
@property (nonatomic, assign) JYFileType fileType;

@end
