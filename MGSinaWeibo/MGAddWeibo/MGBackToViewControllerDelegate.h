//
//  MGBackToSelfInfoViewControllerDelegate.h
//  MGSinaWeibo
//
//  Created by LEON on 14/12/18.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MGAddWeiboViewController;

@protocol MGBackToViewControllerDelegate <NSObject>

@optional

-(void) didClickedDismissButton:(BOOL)isSuccess;
-(void) saveDraft:(NSString *)weiboText andPhotoArray:(NSMutableArray *)photoArray;

@end
