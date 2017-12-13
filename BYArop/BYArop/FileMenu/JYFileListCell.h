//
//  JYFileListCell.h
//  JZMProject
//
//  Created by 龚爱荣 on 16/9/20.
//  Copyright © 2016年 金掌门科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JYFileModel.h"

@protocol JYFileListCellDelegate <NSObject>

- (void)showFileDetail:(UIButton *)btn;

@end

@interface JYFileListCell : UITableViewCell

@property (nonatomic, strong) UIButton *pickBtn;
@property (nonatomic, strong) UIButton *iconBtn;
@property (nonatomic, strong) UILabel *titleL;
@property (nonatomic, strong) UILabel *sizeL;
@property (nonatomic, strong) UILabel *timeL;
@property (nonatomic, weak) id<JYFileListCellDelegate> delegate;
@property (nonatomic, strong) JYFileModel *fileModel;

+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
- (void)onPick:(NSMutableArray *)selectAry;

@end
