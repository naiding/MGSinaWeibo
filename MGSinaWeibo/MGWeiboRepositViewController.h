//
//  MGWeiboRepositViewController.h
//  MGSinaWeibo
//
//  Created by LEON on 15/1/3.
//  Copyright (c) 2015年 LEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGBackToViewControllerDelegate.h"

@interface MGWeiboRepositViewController : UIViewController<UITextViewDelegate>


@property (strong, nonatomic) IBOutlet UITextView *repositText;
- (IBAction)Send:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *inputState;
@property (strong, nonatomic) Status *status;
@property (strong, nonatomic) IBOutlet UIImageView *verifiedImage;

@property (nonatomic, weak) id<MGBackToViewControllerDelegate>delegate;


@property (strong, nonatomic) IBOutlet UIView *fromView;
@property (strong, nonatomic) IBOutlet UILabel *fromNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *fromContentLabel;
@property (strong, nonatomic) IBOutlet UIImageView *fromHeadImage;

@end
