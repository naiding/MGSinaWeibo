//
//  MGPersonalnfoView.h
//  MGSinaWeibo
//
//  Created by LEON on 14/12/28.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGWeiboModel.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

@interface MGPersonalnfoView : UIView


-(id) initWithUser: (User *) user;

@property (strong,nonatomic) User *me;
@property (strong, nonatomic) UIImageView *HeadImage;
@property (strong, nonatomic) UIImageView *BgImage;
@property (strong, nonatomic) UILabel *name;
@property (strong, nonatomic) UILabel *weibo;
@property (strong, nonatomic) UILabel *following;
@property (strong, nonatomic) UILabel *follower;
@property (strong, nonatomic) UILabel *profile;
@property (strong, nonatomic) UILabel *location;
@property (strong, nonatomic) UIVisualEffectView *blur;
@property (strong, nonatomic) UIButton *weiboBtn;
@property (strong, nonatomic) UIButton *followingBtn;
@property (strong, nonatomic) UIButton *followerBtn;


@end
