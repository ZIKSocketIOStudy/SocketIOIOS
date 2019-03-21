//
//  FLMessageInputView_Add.m
//  FLSocketIM
//
//  Created by 冯里 on 10/08/2017.
//  Copyright © 2017 冯里. All rights reserved.
//

#import "FLMessageInputView_Add.h"

@implementation FLMessageInputView_Add

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = FLBackGroundColor;
        UIButton *photoItem = [self buttonWithImageName:@"keyboard_add_photo" title:@"照片" index:0];
        UIButton *cameraItem = [self buttonWithImageName:@"keyboard_add_camera" title:@"拍摄" index:1];
        UIButton *locationItem = [self buttonWithImageName:@"keyboard_add_location" title:@"位置" index:2];
        UIButton *videoItem = [self buttonWithImageName:@"keyboard_add_Video" title:@"视频通话" index:3];
        [self addSubview:photoItem];
//        [self addSubview:cameraItem];
//        [self addSubview:locationItem];
//        [self addSubview:videoItem];
    }
    return self;
}

- (UIButton *)buttonWithImageName:(NSString *)imageName title:(NSString *)title index:(NSInteger)index{
    CGFloat itemWidth = (kScreenWidth- 2*kMargin)/4;
    CGFloat itemHeight = 90;
    CGFloat iconWidth = 57;
    CGFloat leftX = kMargin, topY = 10;
    UIButton *addItem = [[UIButton alloc] initWithFrame:CGRectMake(leftX +index*itemWidth +(itemWidth -iconWidth)/2, topY, iconWidth, itemHeight)];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = [UIColor colorWithHex:0x666666];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = title;
    [titleLabel sizeToFit];
    titleLabel.frame = CGRectMake((iconWidth - titleLabel.width)/2.0, itemHeight - 20, titleLabel.width, 20);
    [addItem addSubview:titleLabel];
    
    [addItem setImageEdgeInsets:UIEdgeInsetsMake(-15, 0, 15, 0)];
    [addItem setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    addItem.tag = 2000+index;
    [addItem addTarget:self action:@selector(clickedItem:) forControlEvents:UIControlEventTouchUpInside];
    return addItem;
}

- (void)clickedItem:(UIButton *)sender{
    NSInteger index = sender.tag - 2000;
    if (_addIndexBlock) {
        _addIndexBlock(index);
    }
}
@end
