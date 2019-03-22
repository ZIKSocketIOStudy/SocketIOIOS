//
//  ZIKRegisterViewController.m
//  FLSocketIM
//
//  Created by ZIKong on 2019/3/21.
//  Copyright © 2019 冯里. All rights reserved.
//

#import "ZIKRegisterViewController.h"
#import "ZIKRegisterProtocolViewController.h"

@interface ZIKRegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *yanTextField;
@property (weak, nonatomic) IBOutlet TOGetCodeButton *getButton;

@end

@implementation ZIKRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"注册";
    
    [_getButton setTitle:@"获取验证码" forState:UIControlStateNormal];

    UIImage * bkgN = [[UIImage imageNamed:@"icon_return"] stretchableImageWithLeftCapWidth:19 topCapHeight:0];
    UIImage * bkgD = [[UIImage imageNamed:@"icon_return"] stretchableImageWithLeftCapWidth:19 topCapHeight:0];
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 60, 44);
    [btn setBackgroundImage:bkgN forState:UIControlStateNormal];
    [btn setBackgroundImage:bkgD forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * itemLeft = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = itemLeft;

}

- (void)popViewController {
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)clickCode:(UIButton *)sender {

    if ([self isBlankWithStr:_phoneTextField.text]) {
        [self showHint:@"请输入手机号"];
    }
    else {
        if (![self verificationIsValidWithPhoneNumberStr:_phoneTextField.text]) {
            [self showHint:@"请输入正确的手机号"];
        }
        else {
            [_getButton timeFailBeginFrom:60];
        }
    }
}

- (IBAction)registerButton:(UIButton *)sender {
    [self.view endEditing:YES];
    if ([self isBlankWithStr:_nameTextField.text]) {
        [self showHint:@"请输入账号"];
    }
    else if ([self isBlankWithStr:_passwordTextField.text]) {
        [self showHint:@"请输入密码"];
    }
    else if ([self isBlankWithStr:_phoneTextField.text])
    {
        [self showHint:@"请输入手机号"];
    }
    else if (![self verificationIsValidWithPhoneNumberStr:_phoneTextField.text]) {
        [self showHint:@"请输入正确的手机号"];
    }
    else if ([self isBlankWithStr:_yanTextField.text]) {
        [self showHint:@"请输入验证码"];
    }
    else if (_yanTextField.text.length != 7) {
        [self showHint:@"请输入正确的验证码"];
    }

    else {
        [self showMessage:@"正在注册中"];
        __weak typeof(self) weakSelf = self;
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"userName"] = _nameTextField.text;
        parameters[@"password"] = _passwordTextField.text;
        [FLNetWorkManager ba_requestWithType:Post withUrlString:Register_Url withParameters:parameters withSuccessBlock:^(id response) {
            
            [weakSelf hideHud];
            if([response[@"code"] integerValue] < 0) {
                [FLAlertView showWithTitle:@"注册失败" message:response[@"message"] cancelButtonTitle:@"确定" otherButtonTitles:nil andAction:nil andParentView:nil];
            }else {
//                [FLAlertView showWithTitle:@"🎉注册成功" message:nil cancelButtonTitle:@"确定" otherButtonTitles:nil andAction:nil andParentView:nil];
                [FLAlertView showWithTitle:@"注册成功" message:nil cancelButtonTitle:@"确定" otherButtonTitles:nil andAction:^(NSInteger buttonIndex) {
                    [self popViewController];
                } andParentView:self.view];
            }
            
        } withFailureBlock:^(NSError *error) {
            
            [weakSelf hideHud];
            [weakSelf showError:@"注册失败"];
        }];

    }
}

- (IBAction)protocolBtn:(UIButton *)sender {
    ZIKRegisterProtocolViewController *vc = [[ZIKRegisterProtocolViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  判断字符串是否为空
 *
 *  @param str 字符串
 *
 *  @return bool值
 */
- (BOOL)isBlankWithStr:(NSString *)str
{
    if (str == nil || str == NULL)
    {
        return YES;
    }
    if ([str isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    if ([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        return YES;
    }
    return NO;
}

//验证手机
- (BOOL)verificationIsValidWithPhoneNumberStr:(NSString *)phoneNumber_str
{
    //    NSString * regularExpression = @"^(((13[0-9]{1})|(15[0-9]{1})|(17[0-9]{1})|(18[0-9]{1})|(14[0-9]{1}))+\\d{8})$";
    NSString * regularExpression = @"^(13[0-9]|14[5-9]|15[0-3,5-9]|16[567]|17[0-9]|18[0-9]|19[189])\\d{8}$";
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@" , regularExpression];
    return [predicate evaluateWithObject:phoneNumber_str];
}


@end
