//
//  QQActivity.h
//  JZMProject
//
//  Created by 龚爱荣 on 16/11/7.
//  Copyright © 2016年 金掌门科技. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

@interface QQActivity : UIActivity{
    NSString *title;
    UIImage *image;
    NSURL *url;
    enum QQApiInterfaceReqType type;
}

@end
