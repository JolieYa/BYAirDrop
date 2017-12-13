//
//  JYFileListVC.h
//  JZMProject
//
//  Created by 龚爱荣 on 16/9/20.
//  Copyright © 2016年 金掌门科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JYFileListVCDelegate <NSObject>

- (void)sendFile:(NSArray *)selectAry;

@end

@interface JYFileListVC : UIViewController
@property (nonatomic, weak) id<JYFileListVCDelegate> delegate;
@end
