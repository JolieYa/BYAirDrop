//
//  QQActivity.m
//  JZMProject
//
//  Created by 龚爱荣 on 16/11/7.
//  Copyright © 2016年 金掌门科技. All rights reserved.
//

#import "QQActivity.h"

@implementation QQActivity

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}

- (NSString *)activityType
{
    return NSStringFromClass([self class]);
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[UIImage class]]) {
            return YES;
        }
        if ([activityItem isKindOfClass:[NSURL class]]) {
            return YES;
        }
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[UIImage class]]) {
            image = activityItem;
        }
        if ([activityItem isKindOfClass:[NSURL class]]) {
            url = activityItem;
        }
        if ([activityItem isKindOfClass:[NSString class]]) {
            title = activityItem;
        }
        NSLog(@"QQApiNewsObject title1: %@", activityItem);
    }
}

- (NSData *)thumbImage
{
    if (image) {
        CGFloat width = 100.0f;
        CGFloat height = image.size.height * 100.0f / image.size.width;
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        [image drawInRect:CGRectMake(0, 0, width, height)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *data = UIImagePNGRepresentation(scaledImage);
        return data;
    }
    return nil;
}

- (void)performActivity
{
    NSURL    *utf8String = [NSURL URLWithString:@"http://www.baidu.com"];
    if (!title) {
        title = @" ";
    }
    NSString    *description =@"";
    NSData      *data;
    data = [self thumbImage];

    if (url) {
        QQApiNewsObject     *newsObj = [QQApiNewsObject objectWithURL:url title:title description:description previewImageData:data];
        SendMessageToQQReq  *req = [SendMessageToQQReq reqWithContent:newsObj];
        
        //将内容分享到qq
        //    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
        //将内容分享到qzone
        QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
        NSLog(@"QQApiNewsObject title: %@, url : %@, sent: %d", title, utf8String, sent);
    }
    
    NSLog(@"QQApiNewsObject title: %@, url : %@", title, url);
    
    [self activityDidFinish:YES];
}


@end
