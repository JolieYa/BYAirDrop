//
//  JYFileListCell.m
//  JZMProject
//
//  Created by 龚爱荣 on 16/9/20.
//  Copyright © 2016年 金掌门科技. All rights reserved.
//

#import "JYFileListCell.h"
//#import "UIImage+Common.h"
#import "UIView+CustomAutoLayout.h"

@implementation JYFileListCell

+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *cellStr = @"cell";
    JYFileListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
    if (cell == nil) {
        cell = [[JYFileListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStr];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _pickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pickBtn setImage:[UIImage imageNamed:@"mUnselected"] forState:UIControlStateNormal];
        [_pickBtn setImage:[UIImage imageNamed:@"mSelected"] forState:UIControlStateSelected];
        _pickBtn.userInteractionEnabled = NO;
        [self.contentView addSubview:_pickBtn];
        
        _iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_iconBtn setImage:[UIImage imageNamed:@"input_photo"] forState:UIControlStateNormal];
        [_iconBtn setImage:[UIImage imageNamed:@"input_photo"] forState:UIControlStateHighlighted];
        [_iconBtn addTarget:self action:@selector(tapDetail:) forControlEvents:UIControlEventTouchUpInside];
        _pickBtn.userInteractionEnabled = YES;
        [self.contentView addSubview:_iconBtn];
        
        _titleL = [[UILabel alloc] init];
        _titleL.font = [UIFont systemFontOfSize:15];
        _titleL.textColor = RGBAOF(0x333333, 1.0);
        [self.contentView addSubview:_titleL];
        
        _sizeL = [[UILabel alloc] init];
        _sizeL.font = [UIFont systemFontOfSize:14];
        _sizeL.textColor = RGBAOF(0x999999, 1.0);
        [self.contentView addSubview:_sizeL];
        
        _timeL = [[UILabel alloc] init];
        _timeL.font = [UIFont systemFontOfSize:14];
        _timeL.textColor = RGBAOF(0x999999, 1.0);
        [self.contentView addSubview:_timeL];
    }
    return self;
}

- (void)tapDetail:(UIButton *)btn
{
//    [tap locationInView:self.view];
    
    if ([self.delegate respondsToSelector:@selector(showFileDetail:)]) {
        [self.delegate showFileDetail:btn];
    }
}

- (void)onPick:(NSMutableArray *)selectAry
{
    self.pickBtn.selected = !self.pickBtn.selected;
    if (self.pickBtn.selected) {
        [selectAry addObject:_fileModel];
    } else {
        [selectAry removeObject:_fileModel];
    }
}

- (void)setFileModel:(JYFileModel *)fileModel
{
    _fileModel = fileModel;
    
    [self.iconBtn setImage:[UIImage imageNamed:@"input_photo"] forState:UIControlStateNormal];
    [self.iconBtn setImage:[UIImage imageNamed:@"input_photo"] forState:UIControlStateHighlighted];
    self.titleL.text = fileModel.name;
    self.sizeL.text = [self calculSize:fileModel.size];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];//格式化
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *date = [df stringFromDate:fileModel.creatDate];
    self.timeL.text = date;
}


//计算文件大小
- (NSString *)calculSize:(unsigned long long)size
{
    int loopCount = 0;
    int mod=0;
    while (size >=1024)
    {
        mod = size%1024;
        size /= 1024;
        loopCount++;
        if (loopCount > 4)
        {
            break;
        }
    }
    
    CGFloat rate=1;
    int loop = loopCount;
    while (loop--)
    {
        rate *= 1000.0;
    }
    CGFloat fSize = size + (CGFloat)mod/rate;
    NSString *sizeUnit;
    switch (loopCount)
    {
        case 0:
            sizeUnit = [[NSString alloc] initWithFormat:@"%.0fB",fSize];
            break;
        case 1:
            sizeUnit = [[NSString alloc] initWithFormat:@"%0.1fKB",fSize];
            break;
        case 2:
            sizeUnit = [[NSString alloc] initWithFormat:@"%0.2fMB",fSize];
            break;
        case 3:
            sizeUnit = [[NSString alloc] initWithFormat:@"%0.3fGB",fSize];
            break;
        case 4:
            sizeUnit = [[NSString alloc] initWithFormat:@"%0.4fTB",fSize];
            break;
        default:
            break;
    }
    return sizeUnit;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_pickBtn sizeWith:CGSizeMake(22, 22)];
    [_pickBtn layoutParentVerticalCenter];
    [_pickBtn alignParentLeftWithMargin:13];
    
    [_iconBtn sizeWith:CGSizeMake(56, 56)];
    [_iconBtn layoutParentVerticalCenter];
    [_iconBtn layoutToRightOf:_pickBtn margin:13];
    
    [_titleL sizeWith:CGSizeMake(200, 20)];
    [_titleL alignTop:_iconBtn];
    [_titleL layoutToRightOf:_iconBtn margin:13];
    [_titleL scaleToParentRightWithMargin:13];
    
    [_sizeL sameWith:_titleL];
    [_sizeL layoutBelow:_titleL];
    [_sizeL layoutToRightOf:_iconBtn margin:13];
    [_sizeL scaleToParentRightWithMargin:13];
    
    [_timeL sameWith:_sizeL];
    [_timeL layoutBelow:_sizeL];
    [_sizeL layoutToRightOf:_iconBtn margin:13];
    [_timeL scaleToParentRightWithMargin:13];
}
@end
