//
//  SCTagWriteDemoViewController.m
//  SCTagWriteViewDemo
//
//  Created by chen Yuheng on 15-3-14.
//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#import "SCTagWriteDemoViewController.h"
#import "SCTagWriteView.h"
#import "UIGridView.h"
#import "UIGridViewDelegate.h"
#import "TUCommonTagCell.h"
#import "BVUnderlineButton.h"
#import "UIViewExt.h"

@interface SCTagWriteDemoViewController ()<SCTagWriteViewDelegate,UIGridViewDelegate>
- (void) initGridView;
@property (strong, nonatomic) UIGridView *tagView;
@property (strong, nonatomic) IBOutlet SCTagWriteView *tagWriteView;
@property (strong, nonatomic) NSArray *tagTitles;
@property (nonatomic, strong) NSMutableArray *tagsArray;

@property (strong, nonatomic) IBOutlet BVUnderlineButton *changePIButton;
@property (strong, nonatomic) IBOutlet UILabel *commonTagLabel;
@property (nonatomic, strong) NSMutableArray *commonTags;
@end

@implementation SCTagWriteDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1];
    _tagWriteView.allowToUseSingleSpace = YES;
    _tagWriteView.delegate = self;
    _tagWriteView.layer.cornerRadius=3.0f;
    [_tagWriteView setBackgroundColor:[UIColor whiteColor]];
    
    _tagsArray = [[NSMutableArray alloc]initWithArray:@[@"乐观", @"学霸",@"毕业狗", @"毕业狗重复", @"毕业狗拉开肯德基",@"毕业狗拉开肯德基的我",@"毕业狗拉开肯德基的你"]];
    _tagTitles = [[NSMutableArray alloc]initWithArray:@[@"乐观", @"学霸",@"快乐", @"超级帅",
                                                        @"特别可爱",@"身材好",@"风趣",@"有素质",
                                                        @"性感",@"自信",@"活泼",@"人缘好",
                                                        @"独立",@"文艺",@"温柔体贴",@"爱干净"]];
    [_tagWriteView addTags:_tagsArray];
    
    [self initGridView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tagWriteView:(SCTagWriteView *)view didMakeTag:(NSString *)tag
{
    NSLog(@"added tag = %@", tag);
    [_tagsArray addObject:tag];
}

- (void)tagWriteView:(SCTagWriteView *)view didRemoveTag:(NSString *)tag
{
    NSLog(@"removed tag = %@", tag);
    [_tagsArray removeObject:tag];
}
- (void) initGridView
{
    _tagView=[[UIGridView alloc] initWithFrame:CGRectMake(10.0f, _commonTagLabel.bottom+10.0f, 300.0f, [UIScreen mainScreen].bounds.size.height-64.0F-_tagWriteView.height-_commonTagLabel.height-30.0)];
    _tagView.uiGridViewDelegate=self;
    _tagView.backgroundColor=[UIColor clearColor];
    _tagView.tag=10;
    _tagView.scrollEnabled=NO;
    //去掉分割线
    _tagView.separatorColor=[UIColor clearColor];
    _tagView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tagView];
}

#pragma mark -UIGridViewDelegate
//每一个gridcell的宽度
- (CGFloat) gridView:(UIGridView *)grid widthForColumnAt:(int)columnIndex
{
    return 75.0;
    
}
//gridcell的高度
- (CGFloat) gridView:(UIGridView *)grid heightForRowAt:(int)rowIndex
{
    
    return 140.0/4.0;
}
//每一行的gridcell的个数
- (NSInteger) numberOfColumnsOfGridView:(UIGridView *) grid
{
    return 4;
}

//gridcell的数量
- (NSInteger) numberOfCellsOfGridView:(UIGridView *) grid
{
    
    return [_tagTitles count];
    
    
}
//生成gridcell
- (UIGridViewCell *) gridView:(UIGridView *)grid cellForRowAt:(int)rowIndex AndColumnAt:(int)columnIndex
{
    TUCommonTagCell *cell = (TUCommonTagCell *)[grid dequeueReusableCell];
    NSString *tagText=_tagTitles[columnIndex+[self numberOfColumnsOfGridView:grid]*(rowIndex)];
    if (cell==nil) {
        cell = [[TUCommonTagCell alloc] init];
    }
    cell.tagText=tagText;
    cell.backgroundColor=[UIColor clearColor];
    [cell setTitleColor:[UIColor colorWithRed:153/255.0f green:153/255.0f blue:153/255.0f alpha:1] forState:UIControlStateNormal];
    return cell;
}
//点击cell
- (void) gridView:(UIGridView *)grid didSelectRowAt:(int)rowIndex AndColumnAt:(int)colIndex
{
    if(_tagWriteView.tagViews.count >=maxTagNumber)
    {
        return;
    }
    
    NSString *selectContent=_tagTitles[colIndex+[self numberOfColumnsOfGridView:grid]*(rowIndex)];
    [_tagWriteView addTagToLast:selectContent animated:YES];
}
- (IBAction)getMoreCommonTags:(id)sender {
    NSLog(@"here it is");
}


@end
