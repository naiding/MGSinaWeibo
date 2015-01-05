//
//  MGPersonalnfoView.m
//  MGSinaWeibo
//
//  Created by LEON on 14/12/28.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import "MGPersonalnfoView.h"
#import "MGSinaEngine.h"

@interface MGPersonalnfoView()
{
    CGFloat *_currentHeight;
}

@end

@implementation MGPersonalnfoView


-(id) initWithUser:(User *)user
{
    if (self = [super init]) {
        
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:SINA_USER_HEAD_IMAGE];
        
        UIImage *image = [UIImage imageWithData:data];
        self.HeadImage = [[UIImageView alloc]initWithImage:image];
        self.HeadImage.frame = self.frame;
        [self addSubview:self.HeadImage];
        self.me = user;
        [self setPersonalInfo:user];
        
        _currentHeight = 0;
    }
    return self;
}


-(void) setPersonalInfo:(User *)theUser
{
    [self setHeadImage];
    [self setBgImage];
    
    [self addSubview:self.BgImage];
}


-(void) setHeadImage
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.me.profileImageUrl]];
    [self.HeadImage setImageWithURLRequest:request placeholderImage:nil success:nil failure:nil];
    
    [self.HeadImage.layer setCornerRadius:CGRectGetHeight([self.HeadImage.layer bounds]) / 2];
    self.HeadImage.layer.masksToBounds = YES;
    
    self.HeadImage.layer.borderWidth = 2;
    self.HeadImage.layer.borderColor = [[UIColor whiteColor] CGColor];
}

-(void) setBgImage
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.me.coverImagePhoneUrl]];
    [self.BgImage setImageWithURLRequest:request placeholderImage:nil success:nil failure:nil];
    
    self.BgImage.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
    
        //NSLog(@"%s",__FUNCTION__);
}









@end
