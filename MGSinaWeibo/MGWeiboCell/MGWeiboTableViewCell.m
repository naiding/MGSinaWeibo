//
//  MGWeiboTableViewCell.m
//  MGSinaWeibo
//
//  Created by LEON on 14/12/15.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import "MGWeiboTableViewCell.h"

#define kStart 12

@implementation MGWeiboTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.fromText = [[UILabel alloc] init];
    
    self.reposit = [[UIButton alloc]init];
    self.comment = [[UIButton alloc] init];
    
    [self.reposit addTarget:self action:@selector(repositPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.comment addTarget:self action:@selector(commentPressed) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void) repositPressed
{
    [self.delegate repositStatus:self.status];
}

-(void) commentPressed
{
    [self.delegate commentStatus:self.status];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}


-(void) setWeiboCell:(Status *)theStatus
{
    self.status = theStatus;
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
    CGSize MaxSize = CGSizeMake(self.frame.size.width - 2 * kStart,0);
    
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
    CGSize size = [self.content.text boundingRectWithSize:MaxSize options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    
    self.content.frame = CGRectMake(kStart, self.headImage.frame.size.height + self.timeAndFrom.frame.size.height, size.width, size.height);
    
    //如果该条微博为转发微博，则显示转自微博
    if (!theStatus.retweetedStatus.userWeiboInfo.name)
    {
        self.fromView.hidden = YES;
        self.fromText.hidden = YES;
        self.fromView.frame = CGRectMake(0, 0, 0, 0);
    }
    else
    {
        self.fromView.hidden = NO;
        self.fromText.hidden = NO;
        
        //NSLog(@"%zd", self.fromView.subviews.count);
        NSMutableString *fromWeibo = [[NSMutableString alloc] initWithString:@"@"];
        [fromWeibo appendFormat:@"%@:%@",theStatus.retweetedStatus.userWeiboInfo.name,theStatus.retweetedStatus.weiboText];
        self.fromText.numberOfLines = 0;
        self.fromText.attributedText = [self filterLinkWithContent:fromWeibo];
        self.fromText.font = tfont;

        NSDictionary *tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
        CGSize fromTextSize = [fromWeibo boundingRectWithSize:MaxSize options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
        
        [self.fromView addSubview:self.fromText];
        self.fromText.frame = CGRectMake(0,8, fromTextSize.width, fromTextSize.height);
        self.fromView.frame = CGRectMake(kStart, self.content.frame.origin.y + self.content.frame.size.height + 8, self.frame.size.width - 2 * kStart, self.fromText.frame.size.height+8);
        self.fromView.backgroundColor = [UIColor colorWithWhite:0.93 alpha:0.9];

//        if([theStatus.retweetedStatus.thumbnailPic count])
//        {
//            UIImageView *thumbnail = [[UIImageView alloc]initWithFrame:
//                                      CGRectMake(0,16 + fromTextSize.height,100, 100)];
//            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:theStatus.retweetedStatus.thumbnailPic[0]]];
//            [thumbnail setImageWithURLRequest:request placeholderImage:nil success:nil failure:nil];
//            
//            [self.fromView addSubview:thumbnail];
//            self.fromView.frame = CGRectMake(kStart, self.content.frame.origin.y + self.content.frame.size.height + 8, self.frame.size.width - 2 * kStart, self.fromText.frame.size.height+thumbnail.frame.size.height + 24);
//        }
    }
    
    [self.reposit setTitle:@"转发" forState:UIControlStateNormal];
    [self.comment setTitle:@"评论" forState:UIControlStateNormal];
    [self.reposit setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.comment setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    self.reposit.frame = CGRectMake(0, 78 + self.content.frame.size.height + self.fromView.frame.size.height, self.frame.size.width * 0.5, 20);
    self.comment.frame = CGRectMake(self.frame.size.width * 0.5 , 78 + self.content.frame.size.height + self.fromView.frame.size.height, self.frame.size.width * 0.5, 20);
    
    self.reposit.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    self.comment.titleLabel.font = [UIFont systemFontOfSize:14.0f];

    
    [self addSubview:self.reposit];
    [self addSubview:self.comment];
    
    CGRect frame = [self frame];
    frame.size.height = 90 + self.content.frame.size.height + self.fromView.frame.size.height + self.reposit.frame.size.height;
    self.frame = frame;    
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
