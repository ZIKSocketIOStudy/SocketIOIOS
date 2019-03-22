//
//  YXPickButton.m
//  Mobileyx
//
//  Created by changle on 2017/2/28.
//  Copyright © 2017年 youhui. All rights reserved.
//

#import "YXPickButton.h"

@interface YXPickButton ()
@property (nonatomic, weak) UIButton *deleteButton;
@end

@implementation YXPickButton

- (instancetype)init
{
    if (self = [super init]) {
                
    }

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    self.highlighted = NO;
    
    
    NSInteger deleteBtnW = self.width/4;
    NSInteger deleteBtnH = deleteBtnW;
    
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteBtn setImage:[UIImage imageNamed:@"shanchutupian"] forState:UIControlStateNormal];
    deleteBtn.frame = CGRectMake(self.width-deleteBtnW, 0, deleteBtnW, deleteBtnH);
    [deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:deleteBtn];
}


- (void)deleteBtnClicked:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pickBtnDelete:)]) {
        [self.delegate pickBtnDelete:self];
    }
}
@end
