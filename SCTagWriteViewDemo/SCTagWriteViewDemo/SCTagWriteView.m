//
//  SCTagWriteView.m
//  SCTagWriteViewDemo
//
//  Created by chen Yuheng on 15-3-14.
//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#import "SCTagWriteView.h"
#import "XHMessageTextView.h"
#import "NSString+Helper.h"
#import <QuartzCore/QuartzCore.h>

@interface SCTagWriteView  ()<UITextViewDelegate>

@property (nonatomic, strong) XHMessageTextView *inputView;
@property (nonatomic, strong) UIButton *deleteButton;

@property (nonatomic, strong) NSMutableArray *tagsMade;

@property (nonatomic, assign) BOOL readyToDelete;
@property (nonatomic, assign) BOOL readyToFinishMaking;

@end

@implementation SCTagWriteView

#pragma mark - Life Cycle
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initProperties];
        [self initControls];
        
        [self reArrangeSubViews];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initProperties];
    [self initControls];
    
    [self reArrangeSubViews];
}

#pragma mark - Property Get / Set
- (void)setFont:(UIFont *)font
{
    _font = font;
    for (UIButton *btn in _tagViews)
    {
        [btn.titleLabel setFont:_font];
    }
}

- (void)setTagBackgroundColor:(UIColor *)tagBackgroundColor
{
    _tagBackgroundColor = tagBackgroundColor;
    for (UIButton *btn in _tagViews)
    {
        [btn setBackgroundColor:_tagBackgroundColor];
    }
    
    _inputView.layer.borderColor = _tagBackgroundColor.CGColor;
    _inputView.textColor = _tagBackgroundColor;
}

- (void)setTagForegroundColor:(UIColor *)tagForegroundColor
{
    _tagForegroundColor = tagForegroundColor;
    for (UIButton *btn in _tagViews)
    {
        [btn setTitleColor:_tagForegroundColor forState:UIControlStateNormal];
    }
}

- (void)setMaxTagLength:(int)maxTagLength
{
    _maxTagLength = maxTagLength;
}

- (NSArray *)tags
{
    return _tagsMade;
}

- (void)setFocusOnAddTag:(BOOL)focusOnAddTag
{
    _focusOnAddTag = focusOnAddTag;
    if (_focusOnAddTag)
    {
        [_inputView becomeFirstResponder];
    }
    else
    {
        [_inputView resignFirstResponder];
    }
}

#pragma mark - Interfaces
- (void)clear
{
    _inputView.text = @"";
    [_tagsMade removeAllObjects];
    [self reArrangeSubViews];
}

- (void)setTextToInputSlot:(NSString *)text
{
    _inputView.text = text;
}

- (void)addTags:(NSMutableArray *)tags
{
    for (NSString *tag in tags)
    {
        NSArray *result = [_tagsMade filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF == %@", tag]];
        if (result.count == 0)
        {
            [_tagsMade addObject:tag];
        }
    }
    
    [self reArrangeSubViews];
}

- (void)removeTags:(NSArray *)tags
{
    for (NSString *tag in tags)
    {
        NSArray *result = [_tagsMade filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF == %@", tag]];
        if (result)
        {
            [_tagsMade removeObjectsInArray:result];
        }
    }
    [self reArrangeSubViews];
}

- (void)addTagToLast:(NSString *)tag animated:(BOOL)animated
{
    tag = [tag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    for (NSString *t in _tagsMade)
    {
        if ([tag isEqualToString:t])
        {
            NSLog(@"DUPLICATED!");
            return;
        }
    }
    
    [_tagsMade addObject:tag];
    
    _inputView.text = @"";
    
    [self addTagViewToLast:tag animated:animated];
    [self layoutInputAndScroll];
    
    if ([_delegate respondsToSelector:@selector(tagWriteView:didMakeTag:)])
    {
        [_delegate tagWriteView:self didMakeTag:tag];
    }
}

- (void)removeTag:(NSString *)tag animated:(BOOL)animated
{
    NSInteger foundedIndex = -1;
    for (NSString *t in _tagsMade)
    {
        if ([tag isEqualToString:t])
        {
            NSLog(@"FOUND!");
            foundedIndex = (NSInteger)[_tagsMade indexOfObject:t];
            break;
        }
    }
    
    if (foundedIndex == -1)
    {
        return;
    }
    
    [_tagsMade removeObjectAtIndex:foundedIndex];
    
    [self removeTagViewWithIndex:foundedIndex animated:animated completion:^(BOOL finished){
        //[self loadAllDeleteButtons];
        [self layoutInputAndScroll];
    }];
    
    if ([_delegate respondsToSelector:@selector(tagWriteView:didRemoveTag:)])
    {
        [_delegate tagWriteView:self didRemoveTag:tag];
    }
}

#pragma mark - Internals
- (void)initControls
{
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.scrollsToTop = YES;
    _scrollView.scrollEnabled=YES;
    _scrollView.showsVerticalScrollIndicator = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_scrollView];
    CGRect inputFrame = CGRectMake(0.0f,0.0f,100.0f,
                                   30.0f);
    _inputView = [[XHMessageTextView alloc] initWithFrame:inputFrame];
    _inputView.autocorrectionType = UITextAutocorrectionTypeNo;
    _inputView.delegate = self;
    _inputView.returnKeyType = UIReturnKeyDone;
    _inputView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _inputView.scrollsToTop = NO;
    _inputView.scrollEnabled = NO;
    _inputView.placeHolder=@"点击输入新标签";
    _inputView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    [_scrollView addSubview:_inputView];
}

- (void)initProperties
{
    _font = [UIFont systemFontOfSize:15.0f];
    _tagBackgroundColor = [UIColor colorWithRed:153/255.0f green:153/255.0f blue:153/255.0f alpha:1];
    _tagForegroundColor = [UIColor whiteColor];
    _maxTagLength = 10;
    _tagGap = 10.0f;
    
    _tagsMade = [NSMutableArray array];
    _tagViews = [NSMutableArray array];
    _deleteButtons = [NSMutableArray array];
    
    _readyToDelete = NO;
}

- (void)addTagViewToLast:(NSString *)newTag animated:(BOOL)animated
{
    CGFloat posX = [self posXForObjectNextToLastTagView];
    CGFloat posY = [self posYForObjectNextToLastTagView];
    NSLog(@"NEXT WILL BE FROM (%f,%f)",posX,posY);
    
    UIButton *tagBtn = [self tagButtonWithTag:newTag posX:posX posY:posY];
    [_tagViews addObject:tagBtn];
    tagBtn.tag = [_tagViews indexOfObject:tagBtn];
    [_scrollView addSubview:tagBtn];
    
    if (animated)
    {
        tagBtn.alpha = 0.0f;
        [UIView animateWithDuration:0.25 animations:^{
            tagBtn.alpha = 1.0f;
        }];
    }
    [self loadAllDeleteButtons];
    
}

- (void)removeTagViewWithIndex:(NSUInteger)index animated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    NSAssert(index < _tagViews.count, @"incorrected index");
    if (index >= _tagViews.count)
    {
        return;
    }
    
    UIView *deletedView = [_tagViews objectAtIndex:index];
    UIView *deletedButtonView = [_deleteButtons objectAtIndex:index];
    
    [deletedButtonView removeFromSuperview];
    [deletedView removeFromSuperview];
    [_tagViews removeObject:deletedView];
    [_deleteButtons removeObject:deletedButtonView];
    
    void (^layoutBlock)(void) = ^{
        CGFloat posX = _tagGap;
        CGFloat posY = _tagGap;
        for (int idx = 0; idx < _tagViews.count; ++idx)
        {
            UIView *view = [_tagViews objectAtIndex:idx];
            UIView *deleteButtonViewTmp = [_deleteButtons objectAtIndex:idx];
            
            CGRect viewFrame = view.frame;
            viewFrame.origin.x = posX;
            viewFrame.origin.y = posY;
            
            view.frame = viewFrame;
            
            NSLog(@"%f,%f,%f",viewFrame.origin.x,viewFrame.size.width,self.scrollView.frame.size.width);
            
            if(viewFrame.origin.x + viewFrame.size.width > self.scrollView.frame.size.width -10.0f)
            {
                viewFrame.origin.x = _tagGap;
                viewFrame.origin.y += viewFrame.size.height + 10.0f;
                view.frame = viewFrame;
                
                posY += viewFrame.size.height + 10.0f;
                posX= _tagGap + viewFrame.size.width + _tagGap;
            }
            else
            {
                posX += viewFrame.size.width + _tagGap;
            }
            
            CGRect newRect = deleteButtonViewTmp.frame;
            newRect.origin.x = view.frame.origin.x + view.frame.size.width - (deleteButtonViewTmp.frame.size.width * 0.7f);
            newRect.origin.y = view.frame.origin.y - (deleteButtonViewTmp.frame.size.height * 0.5f);
            deleteButtonViewTmp.frame = newRect;
            
            deleteButtonViewTmp.tag = idx;
            view.tag = idx;
        }
    };
    
    if (animated)
    {
        [UIView animateWithDuration:0.25 animations:layoutBlock completion:completion];
    }
    else
    {
        layoutBlock();
    }
    
}

- (void)reArrangeSubViews
{
    CGFloat accumX = _tagGap;
    CGFloat accumY = _tagGap;
    
    NSMutableArray *newTags = [[NSMutableArray alloc] initWithCapacity:_tagsMade.count];
    for (NSString *tag in _tagsMade)
    {
        UIButton *tagBtn = [self tagButtonWithTag:tag posX:accumX posY:accumY];
        [tagBtn setBackgroundColor:[self getNextColorChoiceAtIndex:newTags.count]];
        [newTags addObject:tagBtn];
        tagBtn.tag = [newTags indexOfObject:tagBtn];
        CGRect btnFrame=tagBtn.frame;
        
        NSLog(@"[init]btnframe:(%f,%f,%f,%f)",btnFrame.origin.x,btnFrame.origin.y,btnFrame.size.width,btnFrame.size.height);
        if(btnFrame.origin.y > accumY)
        {
            accumY = btnFrame.origin.y;
            accumX = _tagGap + btnFrame.size.width + _tagGap;
        }
        else
        {
            accumX += tagBtn.frame.size.width + _tagGap;
        }
        
        [_scrollView addSubview:tagBtn];
    }
    
    for (UIView *oldTagView in _tagViews)
    {
        [oldTagView removeFromSuperview];
    }
    _tagViews = newTags;
    
    [self loadAllDeleteButtons];
    [self layoutInputAndScroll];
}

- (void)layoutInputAndScroll
{
    CGFloat accumX = [self posXForObjectNextToLastTagView];
    CGFloat accumY= [self posYForObjectNextToLastTagView];
    
    CGRect inputRect = _inputView.frame;
    inputRect.origin.x = accumX;
    inputRect.origin.y = accumY;
    inputRect.size.width = [self widthForInputViewWithText:_inputView.text];
    
    if(accumX + inputRect.size.width > self.scrollView.frame.size.width-10.0f)
    {
        inputRect.origin.x = _tagGap;
        inputRect.origin.y += inputRect.size.height + 10.0f;
    }
    
    inputRect.size.height = 30.0f;
    _inputView.frame = inputRect;
    _inputView.font = _font;
    _inputView.layer.borderColor = _tagBackgroundColor.CGColor;
    _inputView.layer.borderWidth = 0.5f;
    _inputView.layer.cornerRadius = 3.0f;
    _inputView.backgroundColor = [UIColor clearColor];
    _inputView.textColor = _tagBackgroundColor;
    
    if(_tagViews.count >= maxTagNumber)
    {
        _inputView.hidden=YES;
    }
    else
    {
        _inputView.hidden=NO;
    }
    
    //更新scrollview的contentsize
    CGSize contentSize = _scrollView.contentSize;
    contentSize.height = accumY + inputRect.size.height + 30.0f;
    _scrollView.contentSize = contentSize;
    
    [self setScrollOffsetToShowInputView];
}

- (void)setScrollOffsetToShowInputView
{
    CGRect inputRect = _inputView.frame;
    CGFloat scrollingDelta = (inputRect.origin.y + inputRect.size.height) - (_scrollView.contentOffset.y + _scrollView.frame.size.height);
    if (scrollingDelta >= 0)
    {
        CGSize scrollSize=_scrollView.contentSize;
        scrollSize.height += scrollingDelta + 20.0f;
        _scrollView.contentSize = scrollSize;
        
        CGPoint scrollOffset = _scrollView.contentOffset;
        scrollOffset.y += scrollingDelta + 20.0f;
        _scrollView.contentOffset = scrollOffset;
    }
}

- (CGFloat)widthForInputViewWithText:(NSString *)text
{
    return MAX(130.0, [text sizeWithAttributes:@{NSFontAttributeName:_font}].width + 25.0f);
}

- (CGFloat)posXForObjectNextToLastTagView
{
    CGFloat accumX = _tagGap;
    if (_tagViews.count)
    {
        UIView *last = _tagViews.lastObject;
        accumX = last.frame.origin.x + last.frame.size.width + _tagGap;
    }
    return accumX;
}

//获取最后一个tag的初始y
- (CGFloat)posYForObjectNextToLastTagView
{
    CGFloat accumY = _tagGap;
    if (_tagViews.count)
    {
        UIView *last = _tagViews.lastObject;
        accumY = last.frame.origin.y;
    }
    return accumY;
}

- (UIColor *)getNextColorChoiceAtIndex:(NSInteger)idx
{
    switch (idx % 5) {
        case 0:
        {
            return [UIColor colorWithRed:222/255.0f green:207/255.0f blue:44/255.0f alpha:1];
            break;
        }
        case 1:
        {
            return [UIColor colorWithRed:255/255.0f green:166/255.0f blue:77/255.0f alpha:1];
            break;
        }
        case 2:
        {
            return [UIColor colorWithRed:255/255.0f green:140/255.0f blue:102/255.0f alpha:1];
            break;
        }
        case 3:
        {
            return [UIColor colorWithRed:255/255.0f green:191/255.0f blue:64/255.0f alpha:1];
            break;
        }
        case 4:
        {
            return [UIColor colorWithRed:255/255.0f green:207/255.0f blue:64/255.0f alpha:1];
            break;
        }
        default:
        {
            return [UIColor colorWithRed:222/255.0f green:207/255.0f blue:44/255.0f alpha:1];
            break;
        }
    }
}

- (UIImage *)getNextDeleteButtonAtIndex:(NSInteger)idx
{
    switch (idx % 5) {
        case 0:
        {
            return [UIImage imageNamed:@"delete_1"];
            break;
        }
        case 1:
        {
            return [UIImage imageNamed:@"delete_2"];
            break;
        }
        case 2:
        {
            return [UIImage imageNamed:@"delete_3"];
            break;
        }
        case 3:
        {
            return [UIImage imageNamed:@"delete_4"];
            break;
        }
        case 4:
        {
            return [UIImage imageNamed:@"delete_5"];
            break;
        }
        default:
        {
            return [UIImage imageNamed:@"delete_1"];
            break;
        }
    }
}

#pragma mark -创建tag button
- (UIButton *)tagButtonWithTag:(NSString *)tag posX:(CGFloat)posX posY:(CGFloat)posY
{
    UIButton *tagBtn = [[UIButton alloc] init];
    [tagBtn.titleLabel setFont:_font];
    [tagBtn setBackgroundColor:[self getNextColorChoiceAtIndex:_tagViews.count]];
    [tagBtn setTitleColor:_tagForegroundColor forState:UIControlStateNormal];
    [tagBtn addTarget:self action:@selector(tagButtonDidPushed:) forControlEvents:UIControlEventTouchUpInside];
    [tagBtn setTitle:tag forState:UIControlStateNormal];
    
    CGRect btnFrame = tagBtn.frame;
    btnFrame.origin.x = posX;
    btnFrame.origin.y = posY;
    btnFrame.size.width = [tagBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_font}].width + (tagBtn.layer.cornerRadius * 2.0f) + 20.0f;
    btnFrame.size.height = 30.0f;
    
    if( (btnFrame.origin.x+btnFrame.size.width) > self.scrollView.frame.size.width - 10.0f)
    {
        btnFrame.origin.y += btnFrame.size.height+10.0f;
        btnFrame.origin.x = _tagGap;
    }
    tagBtn.layer.cornerRadius = 3.0f;
    tagBtn.frame = CGRectIntegral(btnFrame);
    
    NSLog(@"btnframe:(%f,%f,%f,%f)",btnFrame.origin.x,btnFrame.origin.y,btnFrame.size.width,btnFrame.size.height);
    
    return tagBtn;
}

- (void)detectBackspace
{
    //    if (_inputView.text.length == 0)
    //    {
    //        if (_readyToDelete)
    //        {
    //            // remove lastest tag
    //            if (_tagsMade.count > 0)
    //            {
    //                NSString *deletedTag = _tagsMade.lastObject;
    //                [self removeTag:deletedTag animated:YES];
    //                _readyToDelete = NO;
    //            }
    //        }
    //        else
    //        {
    //            _readyToDelete = YES;
    //        }
    //    }
    return;
}

- (void)loadAllDeleteButtons
{
    if(_tagViews.count==0)
    {
        //最后清除一遍
        if(_deleteButtons.count>0)
        {
            for(UIView *tmp in _deleteButtons)
            {
                NSLog(@"tag :%ld has been removed!",tmp.tag);
                [tmp removeFromSuperview];
            }
        }
        [_deleteButtons removeAllObjects];
        return;
    }
    else
    {
        if(_deleteButtons.count>0)
        {
            for(UIView *tmp in _deleteButtons)
            {
                NSLog(@"tag :%ld has been removed!",tmp.tag);
                [tmp removeFromSuperview];
            }
        }
        [_deleteButtons removeAllObjects];
        for(UIView *tmp in _tagViews)
        {
            UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 0, 18, 18)];
            [deleteButton setBackgroundImage:[self getNextDeleteButtonAtIndex:_deleteButtons.count] forState:UIControlStateNormal];
            [deleteButton setBackgroundColor:[UIColor colorWithRed:255/255.0f green:166/255.0f blue:77/255.0f alpha:1]];
            [deleteButton addTarget:self action:@selector(deleteTagDidPush:) forControlEvents:UIControlEventTouchUpInside];
            deleteButton.layer.cornerRadius=9.0f;
            deleteButton.layer.borderColor = [UIColor whiteColor].CGColor;
            deleteButton.layer.borderWidth = 2.0f;
            CGRect newRect = deleteButton.frame;
            newRect.origin.x = tmp.frame.origin.x + tmp.frame.size.width - (deleteButton.frame.size.width * 0.7f);
            newRect.origin.y = tmp.frame.origin.y - (deleteButton.frame.size.height * 0.5f);
            deleteButton.frame = newRect;
            
            deleteButton.tag=tmp.tag;
            
            [_scrollView addSubview:deleteButton];
            NSLog(@"this is tag of tagviews:%ld",tmp.tag);
            [_deleteButtons addObject:deleteButton];
        }
    }
}

- (BOOL)isFinishLetter:(NSString *)letter
{
    if ([letter isEqualToString:@"\n"])
    {
        return YES;
    }
    
    if ([letter isEqualToString:@" "])
    {
        if (_allowToUseSingleSpace && _readyToFinishMaking == NO)
        {
            _readyToFinishMaking = YES;
            return NO;
        }
        else
        {
            _readyToFinishMaking = NO;
            return YES;
        }
    }
    else
    {
        _readyToFinishMaking = NO;
    }
    
    return NO;
}

#pragma mark - UI Actions
- (void)tagButtonDidPushed:(id)sender
{
    return;
}

- (void)deleteTagDidPush:(id)sender
{
    UIButton *deleteButton=(UIButton *)sender;
    NSString *tag = [_tagsMade objectAtIndex:deleteButton.tag];
    [self removeTag:tag animated:YES];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([self isFinishLetter:text])
    {
        if (textView.text.length > 0)
        {
            [self addTagToLast:textView.text animated:YES];
            textView.text = @"";
        }
        
        if ([text isEqualToString:@"\n"])
        {
            [textView resignFirstResponder];
        }
        
        return NO;
    }
    
    CGFloat currentWidth = [self widthForInputViewWithText:textView.text];
    CGFloat newWidth = 0;
    NSString *newText = nil;
    
    newText = [NSString stringWithFormat:@"%@%@", textView.text, text];
    newWidth = [self widthForInputViewWithText:newText];
    
    CGRect inputRect = _inputView.frame;
    NSLog(@"%f,%f,%f",inputRect.origin.x,newWidth,self.scrollView.frame.size.width);
    if(inputRect.origin.x + newWidth > self.scrollView.frame.size.width -10.0f)
    {
        return NO;
    }
    else
    {
        CGFloat nextX=[self posXForObjectNextToLastTagView];
        
        //这个地方会有一点误差 小数点后六七位产生的，不知道原因
        if(inputRect.origin.x <= _tagGap+1 && inputRect.origin.y > _tagGap && nextX + newWidth<= self.scrollView.frame.size.width -10.0f)
        {
            inputRect.origin.x = nextX;
            inputRect.origin.y -= inputRect.size.height + 10.0f;
        }
    }
    inputRect.size.width = newWidth;
    _inputView.frame = inputRect;
    
    CGFloat widthDelta = newWidth - currentWidth;
    CGSize contentSize = _scrollView.contentSize;
    contentSize.width += widthDelta;
    _scrollView.contentSize = contentSize;
    
    [self setScrollOffsetToShowInputView];
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if(textView.markedTextRange == nil)
    {
        if([textView.text.trimWhitespace length]>10)
        {
            textView.text = [textView.text substringWithRange:NSMakeRange(0, 10)];
        }
        
        CGFloat currentWidth = textView.frame.size.width;
        CGFloat newWidth = 0;
        
        newWidth = [self widthForInputViewWithText:textView.text];
        
        CGRect inputRect = _inputView.frame;
        NSLog(@"%f,%f,%f",inputRect.origin.x,newWidth,self.scrollView.frame.size.width);
        if(inputRect.origin.x + newWidth > self.scrollView.frame.size.width -10.0f)
        {
            inputRect.origin.x = _tagGap;
            inputRect.origin.y += inputRect.size.height + 10.0f;
        }
        else
        {
            CGFloat nextX=[self posXForObjectNextToLastTagView];
            
            //这个地方会有一点误差 小数点后六七位产生的，不知道原因
            if(inputRect.origin.x <= _tagGap+1 && inputRect.origin.y > _tagGap && nextX + newWidth<= self.scrollView.frame.size.width -10.0f)
            {
                inputRect.origin.x = nextX;
                inputRect.origin.y -= (inputRect.size.height + 10.0f);
            }
        }
        inputRect.size.width = newWidth;
        _inputView.frame = inputRect;
        
        CGFloat widthDelta = newWidth - currentWidth;
        CGSize contentSize = _scrollView.contentSize;
        contentSize.width += widthDelta;
        _scrollView.contentSize = contentSize;
        
        [self setScrollOffsetToShowInputView];
        
        if ([_delegate respondsToSelector:@selector(tagWriteView:didChangeText:)])
        {
            [_delegate tagWriteView:self didChangeText:textView.text];
        }
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([_delegate respondsToSelector:@selector(tagWriteViewDidBeginEditing:)])
    {
        [_delegate tagWriteViewDidBeginEditing:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([_delegate respondsToSelector:@selector(tagWriteViewDidEndEditing:)])
    {
        [_delegate tagWriteViewDidEndEditing:self];
    }
}


@end


