//
//  YXPickImageView.m
//  Mobileyx
//
//  Created by changle on 2017/2/28.
//  Copyright © 2017年 youhui. All rights reserved.
//

#import "YXPickImageView.h"
#import "YXPickButton.h"
#define IS_IOS_7 ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)?YES:NO
#define NavBarHeight ((IS_IOS_7)?65:45)

#define UIScreenWidth                              [UIScreen mainScreen].bounds.size.width
#define UIScreenHeight                             [UIScreen mainScreen].bounds.size.height


@interface YXPickImageView ()<YXPickButtonDeleteDelegate>
@property(nonatomic, strong) NSMutableArray *imageBtnArr;
@property(nonatomic, strong) UIButton       *pickBtn;
@end

@implementation YXPickImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.imageBtnArr  = [[NSMutableArray alloc] initWithCapacity:9];
        self.photos       = [[NSMutableArray alloc] initWithCapacity:9];
        self.photosUrlStr = [[NSMutableArray alloc] initWithCapacity:9];
        
        self.pickImageViewHeight = frame.size.height;
        
        self.pickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.pickBtn setImage:[UIImage imageNamed:@"shangchuanzhaopian"] forState:UIControlStateNormal];
        [self.pickBtn addTarget:self action:@selector(pickImageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.pickBtn];
        [self.imageBtnArr addObject:self.pickBtn];
    }
    
    return self;
}


- (void)pickImageBtnClicked:(UIButton * )pickBtn
{
    //NSLog(@"pickImageBtnClicked!");
    if (self.takePhotoBlock) {
        self.takePhotoBlock();
    }
}

- (void)addImage:(UIImage *)image
{
    if (self.photos.count >= 9) {
        return;
    }
    
    [self.photos addObject:image];
    
    
    YXPickButton *imageBtn = [YXPickButton buttonWithType:UIButtonTypeCustom];
    [imageBtn setBackgroundImage:image forState:UIControlStateNormal];
    imageBtn.delegate = self;
    [imageBtn addTarget:self action:@selector(showImage:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:imageBtn];
    
    [self.imageBtnArr insertObject:imageBtn atIndex:0];
    
    //最多允许添加9张图片
    
    if (self.imageBtnArr.count == 10) {
        
        self.pickBtn.hidden = YES;
    }
    
    [self setNeedsLayout];
}

- (void)addImage:(UIImage *)image imageUrlString:(NSString *)imageUrlString {
    if (self.photos.count >= 9) {
        return;
    }
    
    [self.photos addObject:image];
    [self.photosUrlStr addObject:imageUrlString];
    
    
    YXPickButton *imageBtn = [YXPickButton buttonWithType:UIButtonTypeCustom];
    imageBtn.imageUrlString = imageUrlString;
    [imageBtn setBackgroundImage:image forState:UIControlStateNormal];
    imageBtn.delegate = self;
    [imageBtn addTarget:self action:@selector(showImage:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:imageBtn];
    
    [self.imageBtnArr insertObject:imageBtn atIndex:0];
    
    //最多允许添加9张图片
    
    if (self.imageBtnArr.count == 10) {
        
        self.pickBtn.hidden = YES;
    }
    
    [self setNeedsLayout];
}


- (void)showImage:(UIButton *)button {
    if (self.imageShowBlock) {
        self.imageShowBlock(button.tag,button.currentBackgroundImage);
    }
}


- (void)removeImage:(UIImage *)image
{
    [self.photos removeObject:image];
    NSArray *imageArray = [NSArray arrayWithArray:self.imageBtnArr];
    
    __weak typeof(self) weakSelf = self;
    [imageArray enumerateObjectsUsingBlock:^(YXPickButton *button, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([button.currentBackgroundImage isEqual:image]) {
            [self.photosUrlStr removeObject:button.imageUrlString];
            [button removeFromSuperview];
            [weakSelf.imageBtnArr removeObject:button];
            *stop = YES;
        }
    }];
    [self setNeedsLayout];
    if (self.photos.count < 9) {
        self.pickBtn.hidden = NO;
    }
    
}

- (void)removeImage:(UIImage *)image imageUrlString:(NSString *)imageUrlString {
    [self.photos removeObject:image];
    [self.photosUrlStr removeObject:imageUrlString];
    NSArray *imageArray = [NSArray arrayWithArray:self.imageBtnArr];
    
    __weak typeof(self) weakSelf = self;
    [imageArray enumerateObjectsUsingBlock:^(YXPickButton *button, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([button.currentBackgroundImage isEqual:image]) {
            [button removeFromSuperview];
            [weakSelf.imageBtnArr removeObject:button];
            *stop = YES;
        }
    }];
    [self setNeedsLayout];
    if (self.photos.count < 9) {
        self.pickBtn.hidden = NO;
    }

}

- (void)layoutSubviews
{
    
    UIScrollView *scrollView = (UIScrollView *)self.superview;
    
    NSInteger row_nums = 4;
    CGFloat marginX = 10;
    CGFloat imageViewW = (UIScreenWidth - (row_nums+1)*marginX)/row_nums;
    CGFloat imageViewH = imageViewW;
    
    CGFloat imageViewX = 0;
    CGFloat imageViewY = 0;
    
    for(NSInteger i = 0; i< self.imageBtnArr.count; i++)
    {
        imageViewX  = marginX + i%row_nums*(marginX + imageViewW);
        imageViewY = marginX + i/row_nums*(marginX + imageViewH);
        
        YXPickButton *imageView = self.imageBtnArr[i];
        imageView.tag = i;
        imageView.frame = CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);
        
    }
    
    UIButton *lastImageBtn= [self.imageBtnArr lastObject];
    self.height = CGRectGetMaxY(lastImageBtn.frame) + marginX;
    
    NSString *heightStr = [NSString stringWithFormat:@"%f",self.height];
    NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:heightStr,@"height", nil];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshTableViewFrame" object:info];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshTableViewFrame" object:nil userInfo:info];
    
    
    if (CGRectGetMaxY(self.frame) + marginX > UIScreenHeight) {
        
        scrollView.contentSize = CGSizeMake(UIScreenWidth, CGRectGetMaxY(self.frame) + marginX + NavBarHeight);
        self.pickImageViewHeight = scrollView.contentSize.height;
        NSString *heightStr = [NSString stringWithFormat:@"%f",scrollView.contentSize.height];
        NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:heightStr,@"height", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshTableViewFrame" object:info];
    }
}


- (void)pickBtnDelete:(YXPickButton *)pickBtn
{
    UIImage *image = [pickBtn currentBackgroundImage];
    [self.photosUrlStr removeObject:pickBtn.imageUrlString];
    [self.photos removeObject:image];
    [pickBtn removeFromSuperview];
    [self.imageBtnArr removeObject:pickBtn];
    [self setNeedsLayout];
    if (self.photos.count < 9) {
        self.pickBtn.hidden = NO;
    }
}



@end
