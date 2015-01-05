
//
//  MGInfoViewController.m
//  MGSinaWeibo
//
//  Created by LEON on 14/12/10.
//  Copyright (c) 2014年 LEON. All rights reserved.
//


#import "MGInfoViewController.h"
#import "MGAddWeiboViewController.h"
#import "BouncePresentAnimation.h"
#import "SwipeUpInteractiveTransition.h"
#import "NormalDismissAnimation.h"
#import "MGLoginViewController.h"

#import "MGWeiboCommentViewController.h"
#import "MGWeiboRepositViewController.h"
#import "MGDetailWeiboViewController.h"


@interface MGInfoViewController ()

@property (weak, nonatomic) IBOutlet UITableView *selfInfoTableView;
@property (strong, nonatomic) NSMutableDictionary *meInfo;
- (IBAction)addWeibo:(id)sender;

@property (nonatomic, strong) NormalDismissAnimation *dismissAnimation;
@property (nonatomic, strong) BouncePresentAnimation *presentAnimation;
@property (nonatomic, strong) SwipeUpInteractiveTransition *transitionController;

- (IBAction)Logout:(id)sender;

@end

@implementation MGInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    _presentAnimation = [BouncePresentAnimation new];
    _dismissAnimation = [NormalDismissAnimation new];
    _transitionController = [SwipeUpInteractiveTransition new];
    
    self.dataSource = [[MGSelfInfoTableViewDataSource alloc] initWithSelfInfo:[[NSUserDefaults standardUserDefaults] objectForKey:SINA_USER_ID_KEY] CompleteBlock:^{
        [self.selfInfoTableView reloadData];
    }];
    self.selfInfoTableView.dataSource = self.dataSource;
    
    [self setupRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (section == 0) {
//        return 200;
//    }
//    return 0;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if(section == 0)
//    {
//        return self.dataSource.personalInfoView;
//    }
//    
//    return nil;
//}


- (IBAction)addWeibo:(id)sender {
    MGAddWeiboViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MGAddWeiboViewController"];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
    //[self presentViewController:vc animated:YES completion:nil];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > 0) {
        MGDetailWeiboViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MGDetailWeiboViewController"];
        [vc setDetailStatus:self.dataSource.selfWeiboArray[indexPath.row - 1]];
        [self.navigationController pushViewController:vc animated:YES];

    }
}

-(void)saveDraft:(NSString *)weiboText andPhotoArray:(NSMutableArray *)photoArray
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"新浪微博"
                                                                   message:@"保存为草稿?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"是"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
                                                
                                                [[NSUserDefaults standardUserDefaults]setObject:weiboText forKey:@"SINA_TEXT_WAITING_TO_SEND"];
                                                [[NSUserDefaults standardUserDefaults]setObject:photoArray forKey:@"SINA_PHOTO_ARRAY_WAITING_TO_SEND"];
                                                [[NSUserDefaults standardUserDefaults]synchronize];
                                                
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"SINA_TEXT_WAITING_TO_SEND"];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"SINA_PHOTO_ARRAY_WAITING_TO_SEND"];
        
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];

}

-(void)didClickedDismissButton:(BOOL)isSuccess
{
    [self.navigationController popViewControllerAnimated:YES];
    
    if (isSuccess) [self sendStatusInfo:@"微博提醒" andSubtitle:@"微博发送成功" andDone:@"嗯嗯！"];
    else [self sendStatusInfo:@"微博提醒" andSubtitle:@"微博发送失败" andDone:@"好吧！"];
}

-(void) sendStatusInfo:(NSString *)title andSubtitle:(NSString *)subtitle andDone:(NSString *)done
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:subtitle
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:done
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
                                                NSLog(@"Action 1 Handler Called");
                                            }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}



/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [self.selfInfoTableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    
    [self.selfInfoTableView headerBeginRefreshing];
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.selfInfoTableView addFooterWithTarget:self action:@selector(footerRereshing)];
    
    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
    self.selfInfoTableView.headerPullToRefreshText = @"下拉刷新";
    self.selfInfoTableView.headerReleaseToRefreshText = @"松开马上刷新了";
    self.selfInfoTableView.headerRefreshingText = @"正在刷新";
    
    self.selfInfoTableView.footerPullToRefreshText = @"上拉加载更多微博";
    self.selfInfoTableView.footerReleaseToRefreshText = @"松开加载更多微博";
    self.selfInfoTableView.footerRefreshingText = @"正在加载";
}

#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
    [self.dataSource SelfWeibo:YES completeBlock:^{
        [self.selfInfoTableView reloadData];
        [self.selfInfoTableView headerEndRefreshing];
    }];
}

- (void)footerRereshing
{
  [self.dataSource SelfWeibo:NO completeBlock:^{
        [self.selfInfoTableView reloadData];
        [self.selfInfoTableView footerEndRefreshing];
    }];
}


-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self.dismissAnimation;
}

-(id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    return self.transitionController.interacting ? self.transitionController : nil;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self.presentAnimation;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource tableView:self.selfInfoTableView cellForRowAtIndexPath:indexPath].frame.size.height;
}


- (IBAction)Logout:(id)sender {
    
    [MGSinaEngine logout];
    
    UITabBarController *login = [self.storyboard instantiateViewControllerWithIdentifier:@"MGLoginViewController"];
    
    login.transitioningDelegate = self;
    //login.delegate = self;
    //[self.transitionController wireToViewController:login];
    
    [self presentViewController:login animated:YES completion:nil];
}






























/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/




//- (void) loadInitialData
//{
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSData* data  = [userDefaults objectForKey:@"meInfo"];
//    _meInfo = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//    if (!_meInfo) {
//        _meInfo = [NSMutableDictionary dictionary];
//    }
//}
//
//-(void) saveData
//{
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//
//    [userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:_meInfo] forKey:@"meInfo"];
//    [userDefaults synchronize];
//}
//
//-(void) loadFromDictionary
//{
//    self.HeadImage = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[self.meInfo objectForKey:@"headImage"]]];
//    self.BgImage = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[self.meInfo objectForKey:@"bgImage"]]];
//
//
//    self.name.text = [_meInfo objectForKey:@"name"];
//    self.weibo.text = [_meInfo objectForKey:@"weibo"];
//    self.following.text = [_meInfo objectForKey:@"following"];
//    self.follower.text = [_meInfo objectForKey:@"follower"];
//    self.profile.text = [_meInfo objectForKey:@"profile"];
//    self.location.text = [_meInfo objectForKey:@"location"];
//
//    self.name.text = @"妈哥妈哥-_-";
//
//}
//
//-(void) saveToDictionary
//{
//    [_meInfo removeAllObjects];
//
//    NSData *headImageData = UIImagePNGRepresentation(self.HeadImage.image);
//    [_meInfo setObject: headImageData forKey:@"headImage"];
//
//    NSData *bgImageData = UIImagePNGRepresentation(self.BgImage.image);
//    [_meInfo setObject: bgImageData forKey:@"bgImage"];
//
//    [_meInfo setObject:self.name.text forKey:@"name"];
//    [_meInfo setObject:self.weibo.text forKey:@"weibo"];
//    [_meInfo setObject:self.following.text forKey:@"following"];
//    [_meInfo setObject:self.follower.text forKey:@"follower"];
//    [_meInfo setObject:self.profile.text forKey:@"profile"];
//    [_meInfo setObject:self.location.text forKey:@"location"];
//}



@end
