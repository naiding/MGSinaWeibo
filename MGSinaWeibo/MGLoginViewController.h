//
//  MGLoginViewController.h
//  MGSinaWeibo
//
//  Created by LEON on 14/12/10.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGIntroPage.h"
#import "MGIntroView.h"
#import "MGSinaEngine.h"

@interface MGLoginViewController : UIViewController<UIWebViewDelegate,MGIntroDelegate>
{
    UIWebView *_webView;
    void (^_completionHandler)(BOOL);
}

@property (strong, nonatomic) IBOutlet UIButton *loginBtn;
@property (nonatomic, copy)void (^completionHandler)(BOOL);

@property (nonatomic, strong) UIView *customNavBar;

@property (weak, nonatomic) IBOutlet UIButton *Weibo;
@property (nonatomic, assign) CGRect originalBounds;
@property (nonatomic, assign) CGPoint originalCenter;

@property (nonatomic) UIDynamicAnimator *animator;
@property (nonatomic) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic) UIPushBehavior *pushBehavior;
@property (nonatomic) UIDynamicItemBehavior *itemBehavior;


- (id)initWithLoginCompletion:(void (^)(BOOL isLoginSuccess))isLoginSuccess;
- (void)startRequest;

@end
