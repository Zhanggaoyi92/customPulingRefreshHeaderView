//
//  ViewController.m
//  自己的下拉刷新控件
//
//  Created by zgy_smile on 16/8/12.
//  Copyright © 2016年 zgy_smile. All rights reserved.
//

#import "ViewController.h"
#import "Fg_RefreshHeaderView.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property(strong,nonatomic)UITableView * tableView;
@property(strong,nonatomic)Fg_RefreshHeaderView * refreshHeaderView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
}

-(void)setupUI {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    if (self.refreshHeaderView == nil) {
        //稍后介绍这个自定义头部视图，继承的是一个view
        Fg_RefreshHeaderView *view = [[Fg_RefreshHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        // 不太理解，添加头部会顶上去，使用clipsToBounds也切不掉。
        [self.tableView addSubview:view];
        self.refreshHeaderView = view;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell.
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return [NSString stringWithFormat:@"Section %ld", section];
    
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [self.refreshHeaderView fgRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [self.refreshHeaderView fgRefreshScrollViewDidEndDragging:scrollView];
    
}

@end
