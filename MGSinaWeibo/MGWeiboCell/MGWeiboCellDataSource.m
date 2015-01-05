//
//  MGWeiboHomeCellDataSource.m
//  MGSinaWeibo
//
//  Created by LEON on 14/12/12.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import "MGWeiboCellDataSource.h"

@implementation MGWeiboCellDataSource


-(id)initWithHomeWeibo:(int)count CompleteBlock:(void (^)(void))block
{
    if (self = [super init])
    {
        [MGSinaEngine getStatusesWithSinceId:0
                                       maxId:0
                                       count:count
                                        page:1
                                     feature:0
                                    trimUser:0
                                     success:^(BOOL isSuccess, NSMutableArray *array)
         {
             if (isSuccess) {
                 self.weiboArray = array;
                 block();
             }
         }];
    }
    return self;
}

-(id)initWithSelfWeibo:(int)count CompleteBlock:(void (^)(void))block
{
    if (self = [super init])
    {
        NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_USER_ID_KEY];
        [MGSinaEngine getUserNewestWeiboWithId:uid
                                        sinceId:0
                                         maxId:0
                                         count:20
                                          page:1
                                       feature:0
                                       baseApp:0
                                      trimUser:0
                                       success:^(BOOL isSuccess, NSMutableArray *array)
            {
                if (isSuccess) {
                    self.weiboArray = array;
                    block();
                }
            }
         ];
    }
    return self;
}

- (void) HomePage:(BOOL)newest completeBlock:(void (^)(NSIndexSet *sectionPath))block
{
    int page = 1;
    if (!newest) page = (int)([self.weiboArray count] / 20 + 1);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [MGSinaEngine getStatusesWithSinceId:0
                                       maxId:0
                                       count:20
                                        page:page
                                     feature:0
                                    trimUser:0
                                     success:^(BOOL isSuccess, NSMutableArray *array)
         {
             if (isSuccess) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (page != 1) {
                         for (Status *temp in array) {
                             [self.weiboArray addObject:temp];
                         }
                     }
                     else self.weiboArray = array;
                     
                     NSIndexSet *indexSet = [[NSIndexSet alloc]initWithIndex:page - 1];
                     block(indexSet);
                 });
             }
         }];
    });
}

-(void) BiFollowing:(BOOL)newest completeBlock:(void (^)(void))block
{
    
    int page = 1;
    if (!newest) page = (int)([self.weiboArray count] / 20 + 1);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [MGSinaEngine getBilateralStatusesWithSinceId:0
                                                maxId:0
                                                count:20
                                                 page:page
                                              feature:0
                                             trimUser:0
                                              success:^(BOOL isSuccess, NSMutableArray *array)
         {
             if (isSuccess) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (page != 1) {
                         for (Status *temp in array) {
                             [self.weiboArray addObject:temp];
                         }
                     }
                     else self.weiboArray = array;
                     block();
                 });
             }
         }];
    });
}

-(void) SelfWeibo:(BOOL)newest completeBlock:(void (^)(void))block
{
    int page = 1;
    if (!newest) page = (int)([self.weiboArray count] / 20 + 1);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_USER_ID_KEY];
        [MGSinaEngine getUserNewestWeiboWithId:uid
                                       sinceId:0
                                         maxId:0
                                         count:20
                                          page:page
                                       feature:0
                                       baseApp:0
                                      trimUser:0
                                       success:^(BOOL isSuccess, NSMutableArray *array)
         {
             if (isSuccess) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (page != 1) {
                         for (Status *temp in array) {
                             [self.weiboArray addObject:temp];
                         }
                     }
                     else self.weiboArray = array;
                     block();
                 });
             }
         }
         ];
    });
}

#pragma Weibo-Datasource

- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView
{
    //return self.weiboArray.count / 20;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return 20;
    return self.weiboArray.count;
}

- (MGWeiboTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MGWeiboTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"weiboCell"];
    if(!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MGWeiboTableViewCell" owner:self options:nil]lastObject];
    }
    
    cell.delegate = tableView.delegate;
    
    [cell setWeiboCell:[self.weiboArray objectAtIndex:indexPath.row]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end
