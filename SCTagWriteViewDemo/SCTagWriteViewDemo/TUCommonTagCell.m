//
//  TUCommonTagCell.m
//  tataUFO
//
//  Created by chen Yuheng on 15-3-13.
//  Copyright (c) 2015年 tataUFO.com. All rights reserved.
//

#import "TUCommonTagCell.h"
#import <QuartzCore/QuartzCore.h> 

@implementation TUCommonTagCell

- (id)init {
    
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, 75, 30);
        [self initSubViews];
        [self addSubview:self.view];
    }
    
    return self;
}

//初始化gridce 根据类型返回标签gridcell和选择后的可编辑的cell
- (void) initSubViews
{
    _tagLabel=[[UILabel alloc] initWithFrame:CGRectMake(5.0f, 2.5f, 65.0f, 25.0f)];
    _tagLabel.font=[UIFont systemFontOfSize:14.0f];
    
    _tagLabel.layer.cornerRadius=3.0f;
    _tagLabel.backgroundColor=[UIColor whiteColor];
    _tagLabel.layer.masksToBounds = YES;//隐藏边界
    [self addSubview:_tagLabel];
    self.userInteractionEnabled=YES;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    _tagLabel.textAlignment=NSTextAlignmentCenter;
    _tagLabel.backgroundColor=[UIColor whiteColor];
    _tagLabel.text=_tagText;
    _tagLabel.textColor=[UIColor colorWithRed:153/255.0f green:153/255.0f blue:153/255.0f alpha:1];
}

@end
