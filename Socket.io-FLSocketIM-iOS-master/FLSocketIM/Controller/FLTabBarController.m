//
//  FLTabBarController.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/6.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLTabBarController.h"
#import "FLNavigationController.h"
#import "FLChatListViewController.h"
#import "FLFriendsAndGroupsViewController.h"
#import "FLMeViewController.h"
#import "FLTabBarView.h"
#import "FLTabBar.h"

//十六进制颜色值转换
#define UIColorFromRGBA(rgbValue , a) [UIColor colorWithRed:((CGFloat)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((CGFloat)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((CGFloat)(rgbValue & 0xFF)) / 255.0 alpha:a]
#define UIColorFromRGB(rgbValue) UIColorFromRGBA(rgbValue , 1.0)
#define RGB(r, g, b)                    [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f]

#define UIColorBlueNavigationBar [UIColor colorWithRed:17/255. green:183/255. blue:243/255. alpha:1]
#define UIColorBlackNavigationBar [UIColor colorWithRed:51/255. green:51/255. blue:51/255. alpha:1]
#define UIColorRedNavigationBar [UIColor colorWithRed:233/255. green:78/255. blue:70/255. alpha:1]

#define UIColorThemeNavigationBar [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] valueForKey:@"UIColorThemeNavigationBar"]]
//屏幕  宽
#define Screen_Width [UIScreen mainScreen].bounds.size.width
//屏幕  高
#define Screen_Height [UIScreen mainScreen].bounds.size.height
#define kTabBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20?83:49)

@interface FLTabBarController () <FLTabBarViewDelegate>

@end

@implementation FLTabBarController


- (instancetype)init {
    if (self = [super init]) {
        
        
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
        
    }
    return self;
}

- (void)commonInit {
    
    FLChatListViewController *chatList = [[FLChatListViewController alloc] init];
    [self addChildViewController:chatList title:@"消息" imageName:@"icon_message_normal" selectedImageName:@"icon_message_select"];
    
    FLFriendsAndGroupsViewController *friends = [[FLFriendsAndGroupsViewController alloc] init];
    [self addChildViewController:friends title:@"联系人" imageName:@"icon_contacts_normal" selectedImageName:@"icon_contacts_select"];

 
    FLMeViewController *me = [[FLMeViewController alloc] init];
    [self addChildViewController:me title:@"设置" imageName:@"icon_mine_normal" selectedImageName:@"icon_mine_select"];

    
//
//    [self setupChildVc:chatList];
//    [self setupChildVc:friends];
//    [self setupChildVc:me];
//
//    FLTabBarView *tabBarView = [[FLTabBarView alloc] initWithFrame:self.tabBar.bounds];
//    tabBarView.backgroundColor = [UIColor whiteColor];
//    [self.tabBar addSubview:tabBarView];
//    tabBarView.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self setValue:[[FLTabBar alloc] init] forKey:@"tabBar"];
    
    [UITabBar appearance].translucent = NO;
    
    self.tabBar.barTintColor = RGBAColor(108, 111, 129, 1);
    
    //设置TabBar背景颜色
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, kTabBarHeight)];
    backView.backgroundColor = RGB(247, 247, 247);
    [self.tabBar insertSubview:backView atIndex:0];
    self.tabBar.opaque = YES;

    
    [self commonInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupChildVc:(UIViewController *)vc {
    
    
    FLNavigationController *nav = [[FLNavigationController alloc] initWithRootViewController:vc];
    
    [self addChildViewController:nav];
}
#pragma mark - FLTabBarViewDelegate
- (void)fl_tabBarView:(FLTabBarView *)tabBarView didSelectItemAtIndex:(NSInteger)index {
    [self setSelectedIndex:index];
}

- (BOOL)fl_tabBarView:(FLTabBarView *)tabBarView shoulSelectItemAtIndex:(NSInteger)index {
    return YES;
}


- (void)addChildViewController:(UIViewController *)childViewController title:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName
{
    childViewController.tabBarItem.title = title;
    [childViewController.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -3)];
    
    childViewController.tabBarItem.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    childViewController.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [childViewController.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0x929292) , NSFontAttributeName : [UIFont systemFontOfSize:10]} forState:UIControlStateNormal];
    childViewController.view.backgroundColor = RGB(247, 247, 247);
    //    [childViewController.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0x40c22e) , NSFontAttributeName : SystemFont(10)} forState:UIControlStateSelected];
    self.tabBar.tintColor =  RGBAColor(59, 171, 253, 1);
    [childViewController.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName :  RGBAColor(59, 171, 253, 1) , NSFontAttributeName : [UIFont systemFontOfSize:10]} forState:UIControlStateSelected];
    
    // 创建 一个导航控制器
    UINavigationController * nc = [[UINavigationController alloc] initWithRootViewController:childViewController];
    // 添加 子控制器
    [self addChildViewController:nc];
}

//self.highlightedColor = RGBAColor(59, 171, 253, 1);
//self.normalColor = RGBAColor(108, 111, 129, 1);
@end
