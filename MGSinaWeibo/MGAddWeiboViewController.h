//
//  MGAddWeiboViewController.h
//  MGSinaWeibo
//
//  Created by LEON on 14/12/18.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGBackToViewControllerDelegate.h"

@interface MGAddWeiboViewController : UIViewController

- (IBAction)getPhoto:(id)sender;

@property (nonatomic, weak) id<MGBackToViewControllerDelegate>delegate;


@end
