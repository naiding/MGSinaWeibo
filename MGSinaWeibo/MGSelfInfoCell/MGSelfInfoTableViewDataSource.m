//
//  MGSelfInfoTableViewDataSource.m
//  MGSinaWeibo
//
//  Created by LEON on 14/12/16.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import "MGSelfInfoTableViewDataSource.h"
#import "MGPersonalnfoView.h"

@interface MGSelfInfoTableViewDataSource()
{
    NSString *_uid;
}

@end

@implementation MGSelfInfoTableViewDataSource

-(id)initWithSelfInfo:(NSString *)uid CompleteBlock:(void (^)(void))block
{
    if (self = [super init])
    {
        _uid = uid;
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
                    
                    [MGSinaEngine getUserInfo:uid
                                      success:^(BOOL isSuccess, User *aUser)
                     {
                         if (isSuccess) {
                            self.personalInfoView = [[MGPersonalnfoView alloc]initWithUser:aUser];
                            self.selfWeiboArray = array;
                            self.me = aUser;
                             block();
                         }
                     }];
                }
            }
         ];
    }
    return self;
}


#pragma Weibo-Datasource


- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.selfWeiboArray count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        MGSelfInfoTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"selfInfoCell"];
        if(!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"MGSelfInfoTableViewCell" owner:self options:nil]lastObject];
        }
        [cell setSelfInfoCell:self.me];
        
        return cell;
    }
    else
    {
        MGWeiboTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"weiboCell"];
        if(!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"MGWeiboTableViewCell" owner:self options:nil]lastObject];
        }
        [cell setWeiboCell:[self.selfWeiboArray objectAtIndex:indexPath.row - 1]];
        
        cell.delegate = tableView.delegate;
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


-(void) SelfWeibo:(BOOL)updateSelfInfo completeBlock:(void (^)(void))block
{
    
    int page = 1;
    if (!updateSelfInfo) page = (int)([self.selfWeiboArray count] / 20 + 1);

        [MGSinaEngine getUserNewestWeiboWithId:_uid
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
                 [MGSinaEngine getUserInfo:_uid
                                   success:^(BOOL isSuccess, User *aUser)
                  {
                      if (isSuccess) {
                              if (page != 1) {
                                  for (Status *temp in array) {
                                      [self.selfWeiboArray addObject:temp];
                                  }
                              }
                              else self.selfWeiboArray = array;
                              self.me = aUser;
                              block();
                      }
                  }];
             }
         }];
}

@end
