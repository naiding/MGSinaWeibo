//
//  MGWeiboViewController.h
//  MGSinaWeibo
//
//  Created by LEON on 14/12/10.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "MGInfoViewController.h"
#import "MGWeiboTableViewCell.h"
#import "MGWeiboCellDataSource.h"
#import "PopoverView.h"
#import "MGBackToViewControllerDelegate.h"

@interface MGWeiboViewController : UIViewController< UITableViewDelegate>

@property (nonatomic, strong) MGWeiboCellDataSource *dataSource;

@end
