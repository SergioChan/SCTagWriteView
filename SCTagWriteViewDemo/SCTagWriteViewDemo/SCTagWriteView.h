//
//  SCTagWriteView.h
//  SCTagWriteViewDemo
//
//  Created by chen Yuheng on 15-3-14.
//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#define maxTagNumber 10

@protocol SCTagWriteViewDelegate;

@interface SCTagWriteView : UIView

//
// appearance
//
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *tagBackgroundColor;
@property (nonatomic, strong) UIColor *tagForegroundColor;
@property (nonatomic, assign) int maxTagLength;
@property (nonatomic, assign) CGFloat tagGap;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *tagViews;
@property (nonatomic, strong) NSMutableArray *deleteButtons;
//
// data
//
@property (nonatomic, readonly) NSArray *tags;

//
// control
//
@property (nonatomic, assign) BOOL focusOnAddTag;
@property (nonatomic, assign) BOOL allowToUseSingleSpace;

@property (nonatomic, weak) id<SCTagWriteViewDelegate> delegate;

- (void)clear;
- (void)setTextToInputSlot:(NSString *)text;

- (void)addTags:(NSMutableArray *)tags;
- (void)removeTags:(NSArray *)tags;
- (void)addTagToLast:(NSString *)tag animated:(BOOL)animated;
- (void)removeTag:(NSString *)tag animated:(BOOL)animated;

@end

@protocol SCTagWriteViewDelegate <NSObject>
@optional
- (void)tagWriteViewDidBeginEditing:(SCTagWriteView *)view;
- (void)tagWriteViewDidEndEditing:(SCTagWriteView *)view;

- (void)tagWriteView:(SCTagWriteView *)view didChangeText:(NSString *)text;
- (void)tagWriteView:(SCTagWriteView *)view didMakeTag:(NSString *)tag;
- (void)tagWriteView:(SCTagWriteView *)view didRemoveTag:(NSString *)tag;

@end
