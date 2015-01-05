//
//  MGWeiboHomeCell.h
//  MGSinaWeibo
//
//  Created by LEON on 14/12/11.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGWeiboModel.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

@interface MGWeiboCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UIImageView *verifiedImage;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *timeAndFrom;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UILabel *from;

-(void) setWeiboCell:(Status *)theStatus;

@end
