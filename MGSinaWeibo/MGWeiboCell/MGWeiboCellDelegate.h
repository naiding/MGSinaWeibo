//
//  MGWeiboCellDelegate.h
//  MGSinaWeibo
//
//  Created by LEON on 15/1/3.
//  Copyright (c) 2015年 LEON. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MGWeiboCellDelegate <NSObject>

-(void) repositStatus:(Status *)status;
-(void) commentStatus:(Status *)status;

@end
