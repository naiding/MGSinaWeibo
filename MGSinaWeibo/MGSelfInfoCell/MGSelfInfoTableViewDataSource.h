//
//  MGSelfInfoTableViewDataSource.h
//  MGSinaWeibo
//
//  Created by LEON on 14/12/16.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGSelfInfoTableViewCell.h"
#import "MGWeiboTableViewCell.h"
@interface MGSelfInfoTableViewDataSource : NSObject <UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *selfWeiboArray;

@property (strong, nonatomic) UIView *personalInfoView;
@property (strong, nonatomic) User *me;

-(id)initWithSelfInfo:(NSString *)uid CompleteBlock:(void (^)(void))block;
-(void) SelfWeibo:(BOOL)updateSelfInfo completeBlock:(void (^)(void))block;

@end
