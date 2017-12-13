//
//  JYDataModel.h
//  BYArop
//
//  Created by admin on 2017/11/3.
//  Copyright © 2017年 XHWL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JYDataModel : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;

+ (NSArray *)modelArrayWithDictArray:(NSArray *)array;

@end
