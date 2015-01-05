//
//  MGDetailWeiboViewController.h
//  MGSinaWeibo
//
//  Created by LEON on 14/12/19.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGWeiboModel.h"

@interface MGDetailWeiboViewController : UIViewController
{
    CGSize _contentSize;
}

@property (strong, nonatomic) IBOutlet UIView *fromView;
@property (strong, nonatomic) IBOutlet UILabel *fromText;
@property (strong, nonatomic) NSMutableArray *photoArray;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIImageView *headImage;
@property (strong, nonatomic) IBOutlet UIImageView *verifiedImage;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *timeAndFrom;
@property (strong, nonatomic) IBOutlet UILabel *content;
@property (strong, nonatomic) IBOutlet UIButton *collectBtn;


@property (nonatomic,strong) Status *status;

-(void) setDetailStatus:(Status *)status;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;


@end
