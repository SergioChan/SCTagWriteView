//
//  UIPlaceHolderTextView.h
//  tataUFO
//
//  Created by gshmac on 13-9-7.
//  Copyright (c) 2013年 tataUFO.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPlaceHolderTextView : UITextView
@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;
@end
