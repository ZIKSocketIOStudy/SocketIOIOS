//
//  FLFriendsAndGroupsViewController.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/6.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLFriendsAndGroupsViewController.h"
#import "FLChatViewController.h"
#import "FLFriendsListCell.h"
#import "FLFriendModel.h"
#import "ZIKCreateGroupViewController.h"

@interface FLFriendsAndGroupsViewController () <UITableViewDelegate, UITableViewDataSource, FLClientManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation FLFriendsAndGroupsViewController

#pragma mark - Lazy
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
#pragma mark - lifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[FLClientManager shareManager] addDelegate:self];
    [self creatUI];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestData];
}

- (void)dealloc {
    [[FLClientManager shareManager] removeDelegate:self];
}
#pragma mark - UI
- (void)creatUI {
    
    self.navigationItem.title = @"联系人";
    
//    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btn setBackgroundImage:[UIImage imageNamed:@"message_add"] forState:UIControlStateNormal];
//    btn.frame = CGRectMake(5, 0, 44, 44);
////    btn.tag = tag;
//    [btn addTarget:self action:@selector(tapRightNavigationBar:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem * barBtnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
//    self.navigationItem.rightBarButtonItem = barBtnItem;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 60;
    [_tableView registerClass:[FLFriendsListCell class] forCellReuseIdentifier:@"FLFriendsListCell"];
    _tableView.tableFooterView = [[UIView alloc] init];
    [_tableView setSeparatorColor:[UIColor colorWithHex:0xe5e5e5]];
    [_tableView setSeparatorInset:UIEdgeInsetsMake(0, 60, 0, 0)];
}

- (void)tapRightNavigationBar:(UIButton *)sender{
    ZIKCreateGroupViewController *vc = [[ZIKCreateGroupViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Request
- (void)requestData {
    
    if (self.dataSource.count > 0) {
        [self.dataSource removeAllObjects];
    }
    __weak typeof(self) weakSelf = self;
    [FLNetWorkManager ba_requestWithType:Get withUrlString:AllUsers_Url withParameters:nil withSuccessBlock:^(id response) {
        
        FLLog(@"%@", response);
        NSArray *allFriends = [NSArray yy_modelArrayWithClass:[FLFriendModel class] json:response[@"data"][@"allUser"]];
        
        for (NSString *onlineUser in response[@"data"][@"onLineUsers"]) {
            if ([onlineUser isKindOfClass:[NSNull class]]) {
                break;
            }
            for (FLFriendModel *friend in allFriends) {
                if ([friend.name isEqualToString:onlineUser]) {
                    friend.isOnline = YES;
                    break;
                }
            }
        }

        [weakSelf.dataSource addObjectsFromArray:allFriends];
        

        if (weakSelf.dataSource.count) {
            
            NSSortDescriptor *isOnlineSD = [NSSortDescriptor sortDescriptorWithKey:@"isOnline" ascending:NO];
            self.dataSource = [[self.dataSource sortedArrayUsingDescriptors:@[isOnlineSD]] mutableCopy];

            [weakSelf.tableView reloadData];
        }
    } withFailureBlock:^(NSError *error) {
        
        [weakSelf showError:@"加载好友失败"];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FLFriendsListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FLFriendsListCell" forIndexPath:indexPath];
    if (self.dataSource.count) {
        cell.model = self.dataSource[indexPath.row];
        cell.iconImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"Fruit-%ld", (indexPath.row % 10)]];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FLChatViewController *chatVC = [[FLChatViewController alloc] initWithToUser:[self.dataSource[indexPath.row] name]];
    chatVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
}

#pragma mark - FLClientManagerDelegate

- (void)clientManager:(FLClientManager *)manager userOnline:(NSString *)userName {
    
    NSInteger index = 0;
    for (FLFriendModel *friends in self.dataSource) {
        if ([friends.name isEqualToString:userName]) {
            friends.isOnline = YES;
            [self showHint:[NSString stringWithFormat:@"%@上线了", userName]];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        index ++;
    }
}

- (void)clientManager:(FLClientManager *)manager userOffline:(NSString *)userName {
    
    NSInteger index = 0;
    for (FLFriendModel *friend in self.dataSource) {
        
        if ([friend.name isEqualToString:userName]) {
            friend.isOnline = NO;
            [self showHint:[NSString stringWithFormat:@"%@下线了", userName]];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        index++;
    }
}

@end
