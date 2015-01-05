//
//  MGWeiboHomeCell.m
//  MGSinaWeibo
//
//  Created by LEON on 14/12/11.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import "MGWeiboCell.h"

@implementation MGWeiboCell

-(void) setWeiboCell:(Status *)theStatus
{
    //该微博拿到用户信息
    User *me = [theStatus userWeiboInfo];
    
    //设置头像
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:me.profileImageUrl]];
    [self.headImage setImageWithURLRequest:request placeholderImage:nil success:nil failure:nil];
    
    //如果有认证的话加V，并且昵称变红
    [self.verifiedImage.layer setCornerRadius:CGRectGetHeight([self.verifiedImage.layer bounds]) / 2];
    self.verifiedImage.layer.masksToBounds = YES;
    self.name.text = [[theStatus userWeiboInfo] screenName];
    if (me.verified)
    {
        self.name.textColor = [UIColor redColor];
        self.verifiedImage.hidden = NO;
    }
    else
    {
        self.name.textColor = [UIColor blackColor];
        self.verifiedImage.hidden = YES;
    }
    
    //设置用户发微博的时间以及来源
    NSMutableString *sourceInfo = [[NSMutableString alloc] initWithString:[self createTime:theStatus.createdAt]];
    
    NSString* Start = @"nofollow\">";
    NSString* Over = @"</a>";
    NSRange rangeStart = [theStatus.source rangeOfString:Start];
    NSRange rangeOver = [theStatus.source rangeOfString:Over];
    NSString *currentString = [[NSString alloc] init];
    
    if (rangeStart.length == 0 || rangeOver.length == 0) {
        currentString = @"微博 weibo.com";
    }
    else
    {
        currentString = [theStatus.source substringWithRange:NSMakeRange(rangeStart.location + rangeStart.length, rangeOver.location - rangeStart.location - rangeStart.length)];
    }
    
    [sourceInfo appendFormat:@"  来自%@",currentString];
    self.timeAndFrom.text = sourceInfo;
    
    //设置微博内容以及frame
    self.content.attributedText = [self filterLinkWithContent:[theStatus weiboText]];
    self.content.numberOfLines = 0;
    
    UIFont *tfont = [UIFont systemFontOfSize:14];
    CGSize MaxSize = CGSizeMake(350,0);
    
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
    CGSize size = [self.content.text boundingRectWithSize:MaxSize options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    
    self.content.frame = CGRectMake(12, self.headImage.frame.size.height + 20, size.width, size.height);
    
    //如果该条微博为转发微博，则显示转自微博
    if (!theStatus.retweetedStatus.userWeiboInfo.name)
    {
        self.from.hidden = YES;
        self.from.frame = CGRectMake(0, 0, 0, 0);
    }
    else
    {
        self.from.hidden = NO;
        
        NSMutableString *fromWeibo = [[NSMutableString alloc] initWithString:@"@"];
        [fromWeibo appendFormat:@"%@:%@",theStatus.retweetedStatus.userWeiboInfo.name,theStatus.retweetedStatus.weiboText];
        
        CGSize MaxSize = CGSizeMake(330,0);
        
        NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
        CGSize fromSize = [fromWeibo boundingRectWithSize:MaxSize options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
        
        self.from.frame = CGRectMake(self.content.frame.origin.x,
                                     self.content.frame.origin.y + self.content.frame.size.height + 8, fromSize.width, fromSize.height);
        self.from.numberOfLines = 0;
        
        self.from.backgroundColor = [UIColor colorWithWhite:0.93 alpha:0.9];
        self.from.attributedText = [self filterLinkWithContent:fromWeibo];
    }
    
//    NSLog(@"content:%f,%f,%f,%f",self.content.frame.origin.x,self.content.frame.origin.y,
//                        self.content.frame.size.width,self.content.frame.size.height);
//    
//    NSLog(@"from:%f,%f,%f,%f",self.from.frame.origin.x,self.from.frame.origin.y,
//          self.from.frame.size.width,self.from.frame.size.height);
    
    CGRect frame = [self frame];
    frame.size.height = 80 + size.height + self.from.frame.size.height;
    self.frame = frame;
    
    
    //NSLog(@"%@",theStatus.retweetedStatus.userWeiboInfo.name );
}

-(NSString *)createTime:(NSString *) createDateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"EEE MMM d HH-mm-ss Z yyyy"];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSDate *createDate = [dateFormatter dateFromString:createDateStr];
    NSDate *nowDate = [NSDate date];
    NSTimeInterval delta = [nowDate timeIntervalSinceDate:createDate];
    
    NSDateFormatter *resultFormatter = [[NSDateFormatter alloc]init];
    [resultFormatter setDateFormat:@"yyyy-MM-dd"];

    if ( delta <= 60) {
        return @"刚刚";
    }
    else if ( delta > 60 && delta < 3600)
    {
        int minute = delta / 60;
        return [NSString stringWithFormat:@"%d分钟前",minute];
    }
    else if ( delta >= 3600 && delta < 86400)
    {
        int hour = delta / 3600;
        return [NSString stringWithFormat:@"%d小时前",hour];
    }
    else
    {
        return [resultFormatter stringFromDate:createDate];
    }
}

- (NSMutableAttributedString *)filterLinkWithContent:(NSString *)content {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content];
    NSError *error = NULL;
    NSDataDetector *detector =
    [NSDataDetector dataDetectorWithTypes:(NSTextCheckingTypes)NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber
                                    error:&error];
    NSArray *matches = [detector matchesInString:content
                                         options:0
                                           range:NSMakeRange(0, [content length])];
    for (NSTextCheckingResult *match in matches) {
        
        if (([match resultType] == NSTextCheckingTypeLink)) {
            
            NSURL *url = [match URL];
            [attributedString addAttribute:NSLinkAttributeName value:url range:match.range];
        }
    }
    return attributedString;
}

@end
