//
//  SwipeUpInteractiveTransition.h
//  presntAndDismissVC
//
//  Created by LEON on 14/12/11.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwipeUpInteractiveTransition : UIPercentDrivenInteractiveTransition
@property (nonatomic, assign) BOOL interacting;
- (void)wireToViewController:(UIViewController*)viewController;
@end

