//
//  YXPickButton.h
//  Mobileyx
//
//  Created by changle on 2017/2/28.
//  Copyright © 2017年 youhui. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YXPickButton;

@protocol YXPickButtonDeleteDelegate <NSObject>

- (void)pickBtnDelete:(YXPickButton *)pickBtn;

@end

@interface YXPickButton : UIButton
@property (nonatomic, copy) NSString *imageUrlString;

@property (nonatomic, weak) id<YXPickButtonDeleteDelegate> delegate;
@end
