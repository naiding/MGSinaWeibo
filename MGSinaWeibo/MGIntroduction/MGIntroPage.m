//
//  MGIntroPage.m
//  MGSinaWeibo
//
//  Created by LEON on 14/12/10.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import "MGIntroPage.h"

@implementation MGIntroPage

+ (MGIntroPage *)page {
    MGIntroPage *newPage = [[MGIntroPage alloc] init];
    newPage.imgPositionY    = 50.0f;
    newPage.titlePositionY  = 160.0f;
    newPage.descPositionY   = 140.0f;
    newPage.title = @"";
    newPage.titleFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0];
    newPage.titleColor = [UIColor whiteColor];
    newPage.desc = @"";
    newPage.descFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0];
    newPage.descColor = [UIColor whiteColor];
    
    return newPage;
}

+ (MGIntroPage *)pageWithCustomView:(UIView *)customV {
    MGIntroPage *newPage = [[MGIntroPage alloc] init];
    newPage.customView = customV;
    
    return newPage;
}

@end
