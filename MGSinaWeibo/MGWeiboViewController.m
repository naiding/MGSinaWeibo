//
//  MGWeiboViewController.m
//  MGSinaWeibo
//
//  Created by LEON on 14/12/10.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import "MGWeiboViewController.h"
#import "MJRefresh.h"
#import "MGDetailWeiboViewController.h"
#import "MGWeiboCellDelegate.h"

#import "MGWeiboRepositViewController.h"
#import "MGWeiboCommentViewController.h"

@interface MGWeiboViewController ()<MGWeiboCellDelegate,MGBackToViewControllerDelegate>
{
    int _currentPage;
}
- (IBAction)homeWeibo:(id)sender;
- (IBAction)catalog:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *weiboTableView;

@end

@implementation MGWeiboViewController


-(void) repositStatus:(Status *)status
{
    MGWeiboRepositViewController *repositVc = [self.storyboard instantiateViewControllerWithIdentifier:@"MGWeiboRepositViewController"];
    repositVc.status = status;
    repositVc.delegate = self;
    
    [self.navigationController pushViewController:repositVc animated:YES];
}

-(void) commentStatus:(Status *)status
{
    MGWeiboCommentViewController *commentVc = [self.storyboard instantiateViewControllerWithIdentifier:@"MGWeiboCommentViewController"];
    commentVc.delegate = self;
    commentVc.status = status;
    
    [self.navigationController pushViewController:commentVc animated:YES];
}

-(void)didClickedDismissButton:(BOOL)isSuccess
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _currentPage = 0;
    self.dataSource = [[MGWeiboCellDataSource alloc] initWithHomeWeibo:20 CompleteBlock:^{
        //[self.weiboTableView reloadData];
    }];
    self.weiboTableView.dataSource = self.dataSource;
    [self setupRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)catalog:(id)sender {
    
    CGPoint point = CGPointMake(self.view.frame.size.width * 0.5,54);
    NSArray *titles = @[@"首页", @"互相关注",@"我的微博"];
    PopoverView *pop = [[PopoverView alloc] initWithPoint:point titles:titles images:nil];
    pop.selectRowAtIndex = ^(NSInteger index){
        _currentPage = (int)index;
        [self.weiboTableView headerBeginRefreshing];
    };
    [pop show];
}


/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [self.weiboTableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    
    [self.weiboTableView headerBeginRefreshing];
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.weiboTableView addFooterWithTarget:self action:@selector(footerRereshing)];
    
    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
    self.weiboTableView.headerPullToRefreshText = @"下拉刷新";
    self.weiboTableView.headerReleaseToRefreshText = @"松开马上刷新了";
    self.weiboTableView.headerRefreshingText = @"正在刷新";
    
    self.weiboTableView.footerPullToRefreshText = @"上拉加载更多微博";
    self.weiboTableView.footerReleaseToRefreshText = @"松开加载更多微博";
    self.weiboTableView.footerRefreshingText = @"正在加载";
}

#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
    if (_currentPage == 0) [self.dataSource HomePage:YES completeBlock: ^(NSIndexSet *index){
        [self.weiboTableView reloadData];
        [self.weiboTableView headerEndRefreshing];
    }];
    else if (_currentPage == 1) [self.dataSource BiFollowing:YES completeBlock:^{
        [self.weiboTableView reloadData];
        [self.weiboTableView headerEndRefreshing];
    }];
    else if (_currentPage == 2) [self.dataSource SelfWeibo:YES completeBlock:^{
        [self.weiboTableView reloadData];
        [self.weiboTableView headerEndRefreshing];
    }];
}

- (void)footerRereshing
{
    if (_currentPage == 0) [self.dataSource HomePage:NO completeBlock:^(NSIndexSet *index){
        
        NSLog(@"%@",index);
        [self.weiboTableView reloadData];
        //[self.weiboTableView reloadSections:index withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.weiboTableView footerEndRefreshing];
    }];
    else if (_currentPage == 1 ) [self.dataSource BiFollowing:NO completeBlock:^{
        [self.weiboTableView reloadData];
        [self.weiboTableView footerEndRefreshing];
    }];
    else if (_currentPage == 2) [self.dataSource SelfWeibo:NO completeBlock:^{
        [self.weiboTableView reloadData];
        [self.weiboTableView footerEndRefreshing];
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)homeWeibo:(id)sender {
    
    [MGSinaEngine sendStatus:@"哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈"
                     picData:nil
                    latFloat:+39.9
                   longFloat:+116.38
                     visible:0
                      listId:nil
                     success:^(BOOL isSuccess, Status *aStatus)
     {
         if (isSuccess) {
         }
     }];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MGDetailWeiboViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MGDetailWeiboViewController"];
    [vc setDetailStatus:self.dataSource.weiboArray[indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource tableView:self.weiboTableView cellForRowAtIndexPath:indexPath].frame.size.height;
}

@end
