//
//  ZIKCreateGroupViewController.m
//  FLSocketIM
//
//  Created by ZIKong on 2019/1/3.
//  Copyright © 2019 冯里. All rights reserved.
//

#import "ZIKCreateGroupViewController.h"
#import "FLClientManager.h"

@interface ZIKCreateGroupViewController ()

@end

@implementation ZIKCreateGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"创建群组";
    
    
    [self showMessage:@"创建中"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"userName"] = [FLClientManager shareManager].currentUserID;
//    parameters[@"password"] = [FLClientManager shareManager].currentUserID;
    parameters[@"group_name"] = @"kongGroup";
    parameters[@"user_id"] = [FLClientManager shareManager].currentUserID;
    __weak typeof(self) weakSelf = self;
    [FLNetWorkManager ba_requestWithType:Post withUrlString:CreateGroup_Url withParameters:parameters withSuccessBlock:^(id response) {
        NSLog(@"response:%@",response);
        [weakSelf hideHud];
        if ([response[@"code"] integerValue] < 0) {
            
            [FLAlertView showWithTitle:response[@"message"] message:nil cancelButtonTitle:@"确定" otherButtonTitles:nil andAction:nil andParentView:nil];
        }
        else {
            
//            [FLUserDefault setObject:parameters forKey:loginAccountInfo];
//            NSString *auth_token = response[@"data"][@"auth_token"];
//            [weakSelf socketConnectWithToken:auth_token];
//            [FLClientManager shareManager].auth_token = auth_token;
//            [FLClientManager shareManager].currentUserID = _userNameField.text;
        }
    } withFailureBlock:^(NSError *error) {
        
        [weakSelf hideHud];
        [weakSelf showError:@"登录失败"];
    }];

}



@end
