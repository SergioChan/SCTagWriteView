//
//  SCCommonTagCell.h
//  SCTagWriteViewDemo
//
//  Created by chen Yuheng on 15-3-15.
//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIGridViewCell.h"
@interface SCCommonTagCell : UIGridViewCell {
@private
    UILabel         *_tagLabel;
}
@property (nonatomic,copy) NSString  *tagText;
@end
