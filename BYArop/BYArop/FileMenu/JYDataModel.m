//
//  JYDataModel.m
//  BYArop
//
//  Created by admin on 2017/11/3.
//  Copyright © 2017年 XHWL. All rights reserved.
//

#import "JYDataModel.h"

@implementation JYDataModel

+ (NSArray *)modelArrayWithDictArray:(NSArray *)array
{
    NSMutableArray *modelAry = [[NSMutableArray alloc] init];
    for (int i=0; i<array.count; i++) {
        NSDictionary *dict = array[i];
        JYDataModel *model = [[JYDataModel alloc] init];
        model.name = dict[@"name"];
        model.type = dict[@"type"];
        [modelAry addObject:model];
    }
    return modelAry;
}
@end
