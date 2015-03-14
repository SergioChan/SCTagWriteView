//
//  TUCommonTagCell.h
//  tataUFO
//
//  Created by chen Yuheng on 15-3-13.
//  Copyright (c) 2015年 tataUFO.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIGridViewCell.h"
@interface TUCommonTagCell : UIGridViewCell {
@private
    UILabel         *_tagLabel;
}
@property (nonatomic,copy) NSString  *tagText;

@end
