//
//  MGInfoViewController.h
//  MGSinaWeibo
//
//  Created by LEON on 14/12/10.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIView.h>
#import <UIKit/UIKitDefines.h>

#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

#import "MGWeiboTableViewCell.h"
#import "MGWeiboCellDataSource.h"

#import "MGSelfInfoTableViewCell.h"
#import "MGSelfInfoTableViewDataSource.h"

#import "PopoverView.h"
#import "MJRefresh.h"

#import "MGBackToViewControllerDelegate.h"
#import "BouncePresentAnimation.h"
#import "SwipeUpInteractiveTransition.h"
#import "NormalDismissAnimation.h"

#import "MGWeiboCellDelegate.h"

@interface MGInfoViewController : UIViewController< UITableViewDelegate,MGBackToViewControllerDelegate,UIViewControllerTransitioningDelegate,MGWeiboCellDelegate>

@property (nonatomic, strong) MGSelfInfoTableViewDataSource *dataSource;


@end
