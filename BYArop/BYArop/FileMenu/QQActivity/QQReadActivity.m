//
//  QQReadActivity.m
//  JZMProject
//
//  Created by 龚爱荣 on 16/11/7.
//  Copyright © 2016年 金掌门科技. All rights reserved.
//

#import "QQReadActivity.h"

@implementation QQReadActivity

- (id)init
{
    self = [super init];
    if (self) {
//        type = WXSceneTimeline;
    }
    return self;
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"icon_login_qq"];
}

- (NSString *)activityTitle
{
    return @"QQ";
}

@end
