//
//  MGWeiboTableViewCell.h
//  MGSinaWeibo
//
//  Created by LEON on 14/12/15.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGWeiboModel.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "MGWeiboCellDelegate.h"

@interface MGWeiboTableViewCell : UITableViewCell
{
    Status *_status;
}

@property (strong, nonatomic) Status *status;
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UIImageView *verifiedImage;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *timeAndFrom;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UIView *fromView;

@property (strong, nonatomic) UIButton *reposit;
@property (strong, nonatomic) UIButton *comment;

@property (strong, nonatomic) UILabel *fromText;

-(void) setWeiboCell:(Status *)theStatus;

@property (assign, nonatomic) id <MGWeiboCellDelegate> delegate;

@end
