//
//  MGWeiboCommentViewController.h
//  MGSinaWeibo
//
//  Created by LEON on 15/1/3.
//  Copyright (c) 2015年 LEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGBackToViewControllerDelegate.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

@interface MGWeiboCommentViewController : UIViewController<UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UITextView *commentText;
@property (strong, nonatomic) IBOutlet UILabel *inputState;
- (IBAction)Send:(id)sender;
@property (strong, nonatomic) Status *status;

@property (nonatomic, weak) id<MGBackToViewControllerDelegate>delegate;

@property (strong, nonatomic) IBOutlet UIView *fromView;
@property (strong, nonatomic) IBOutlet UILabel *fromNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *fromContentLabel;
@property (strong, nonatomic) IBOutlet UIImageView *verifiedImage;
@property (strong, nonatomic) IBOutlet UIImageView *fromHeadImage;

@end
