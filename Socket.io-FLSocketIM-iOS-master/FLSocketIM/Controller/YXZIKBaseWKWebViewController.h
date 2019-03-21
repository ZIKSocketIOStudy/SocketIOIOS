//
//  YXZIKBaseWKWebViewController.h
//  Mobileyx
//
//  Created by ZIKong on 2017/4/21.
//  Copyright © 2017年 youhui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YXZIKBaseWKWebViewController : UIViewController
@property (nonatomic,assign) BOOL unNeedShare;
/**
 加载外部链接网页地址
 
 @param string URL地址
 */
- (void)loadWebURLSring:(NSString *)string;


@end
