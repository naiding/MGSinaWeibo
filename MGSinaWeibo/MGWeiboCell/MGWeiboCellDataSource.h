//
//  MGWeiboHomeCellDataSource.h
//  MGSinaWeibo
//
//  Created by LEON on 14/12/12.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGWeiboTableViewCell.h"

@interface MGWeiboCellDataSource : NSObject <UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *weiboArray;
-(id)initWithHomeWeibo:(int)count CompleteBlock:(void (^)(void))block;
-(id)initWithSelfWeibo:(int)count CompleteBlock:(void (^)(void))block;

- (void) HomePage:(BOOL)newest completeBlock:(void (^)(NSIndexSet *sectionPath))block;
-(void) BiFollowing:(BOOL)newest completeBlock:(void (^)(void))block;
-(void) SelfWeibo:(BOOL)newest completeBlock:(void (^)(void))block;

@end
