//
//  TOGetCodeButton.m
//  WenMingShuo
//
//  Created by changle on 2016/12/26.
//  Copyright © 2016年 Six. All rights reserved.
//

#import "TOGetCodeButton.h"

@interface TOGetCodeButton ()

@property (nonatomic,strong) NSTimer * timer;

@property (nonatomic,assign) NSInteger count;

@end

@implementation TOGetCodeButton

- (void)timeFailBeginFrom:(NSInteger)timeCount {
    self.count = timeCount;
    self.enabled = NO;
    // 加1个计时器
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
}

- (void)timerFired {
    if (self.count != 1) {
        self.count -= 1;
        [self setTitle:[NSString stringWithFormat:@"%@%ld%@",@"剩余", self.count,@"秒"] forState:UIControlStateDisabled];

    } else {
        self.enabled = YES;
        [self setTitle:@"获取验证码" forState:UIControlStateNormal];
        [self.timer invalidate];
    }
}

-(void)reset {
    
    [self.timer invalidate];
    self.timer = nil;
    self.enabled = YES;
    [self setTitle:@"获取验证码" forState:UIControlStateNormal];
}


@end
