//
//  ZIKComplaintViewController.m
//  FLSocketIM
//
//  Created by ZIKong on 2019/3/22.
//  Copyright © 2019 冯里. All rights reserved.
//

#import "ZIKComplaintViewController.h"
#import "TOOpinionsAndFeedbackViewController.h"

@interface ZIKComplaintViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *_titleArray;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

static NSString *cellID= @"cellId";

@implementation ZIKComplaintViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"投诉";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellID];
    self.tableView.tableFooterView = [UIView new];
    
    _titleArray = @[@"色情低俗",@"政治敏感",@"其它"];
    [self.tableView reloadData];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titleArray.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = _titleArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TOOpinionsAndFeedbackViewController *vc = [[TOOpinionsAndFeedbackViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
