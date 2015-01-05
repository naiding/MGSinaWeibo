//
//  MGDetailWeiboViewController.m
//  MGSinaWeibo
//
//  Created by LEON on 14/12/19.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import "MGDetailWeiboViewController.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"


#define kStart 8

@implementation MGDetailWeiboViewController

- (IBAction)collectBtn:(id)sender {
    
    if (self.status.favorited)
    {
        [MGSinaEngine creatOrDestroyFavoriteWithStatusId:self.status.statusId flag:NO success:^(BOOL isSuccess, Favorite *aFavorite)

        {
            if (isSuccess) {
                self.status.favorited = NO;
                [self.collectBtn setImage:[UIImage imageNamed:@"noCollect.png"] forState:UIControlStateNormal];
            }
            else if(!isSuccess)
            {
                NSLog(@"FUCK!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            }
        }];
    }
    else
    {
        [MGSinaEngine creatOrDestroyFavoriteWithStatusId:self.status.statusId flag:YES success:^(BOOL isSuccess, Favorite *aFavorite)
        {
            if (isSuccess) {
                self.status.favorited = YES;
                [self.collectBtn setImage:[UIImage imageNamed:@"isCollect.png"] forState:UIControlStateNormal];
            }
            else if(!isSuccess)
            {
                NSLog(@"FUCK!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            }
        }];
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self segmentIndexChanged:nil];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setDetailStatus:(Status *)status
{
    self.status = status;
}

-(IBAction)segmentIndexChanged:(id)sender
{
    NSLog(@"%ld",self.segmentedControl.selectedSegmentIndex);
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            [self loadMainView];
            self.mainView.hidden = NO;
            break;
        case 1:
            self.mainView.hidden = YES;
            break;
        case 2:
            self.mainView.hidden = YES;
            break;
        default:
            break;
    }
}

-(void) loadMainView
{
    if(self.status.favorited)
    {
        [self.collectBtn setImage:[UIImage imageNamed:@"isCollect.png"] forState:UIControlStateNormal];
    }
    else
    {
        [self.collectBtn setImage:[UIImage imageNamed:@"noCollect.png"] forState:UIControlStateNormal];
    }
    
    //该微博拿到用户信息
    User *me = [self.status userWeiboInfo];
    
    //设置头像
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:me.profileImageUrl]];
    [self.headImage setImageWithURLRequest:request placeholderImage:nil success:nil failure:nil];
    
    //如果有认证的话加V，并且昵称变红
    [self.verifiedImage.layer setCornerRadius:CGRectGetHeight([self.verifiedImage.layer bounds]) / 2];
    self.verifiedImage.layer.masksToBounds = YES;
    self.name.text = [[self.status userWeiboInfo] screenName];
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
    NSMutableString *sourceInfo = [[NSMutableString alloc] initWithString:[self createTime:self.status.createdAt]];
    
    NSString* Start = @"nofollow\">";
    NSString* Over = @"</a>";
    NSRange rangeStart = [self.status.source rangeOfString:Start];
    NSRange rangeOver = [self.status.source rangeOfString:Over];
    NSString *currentString = [[NSString alloc] init];
    
    if (rangeStart.length == 0 || rangeOver.length == 0) {
        currentString = @"微博 weibo.com";
    }
    else
    {
        currentString = [self.status.source substringWithRange:NSMakeRange(rangeStart.location + rangeStart.length, rangeOver.location - rangeStart.location - rangeStart.length)];
    }
    
    [sourceInfo appendFormat:@"  来自%@",currentString];
    self.timeAndFrom.text = sourceInfo;
    
    //设置微博内容以及frame
    self.content.attributedText = [self filterLinkWithContent:[self.status weiboText]];
    self.content.numberOfLines = 0;
    
    UIFont *tfont = [UIFont systemFontOfSize:14];
    CGSize MaxSize = CGSizeMake(self.view.frame.size.width - 4 * kStart,0);
    
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
    CGSize size = [self.content.text boundingRectWithSize:MaxSize options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    _contentSize = size;
    
    self.content.frame = CGRectMake(2 * kStart, kStart + self.headImage.frame.origin.y + self.headImage.frame.size.height, _contentSize.width, _contentSize.height);

    
    //如果该条微博为转发微博，则显示转自微博
    if (!self.status.retweetedStatus.userWeiboInfo.name)
    {
        self.fromView.hidden = YES;
        self.fromText.hidden = YES;
        self.fromView.frame = CGRectMake(0, 0, 0, 0);
    }
    else
    {
        self.fromView.hidden = NO;
        self.fromText.hidden = NO;
        
        NSMutableString *fromWeibo = [[NSMutableString alloc] initWithString:@"@"];
        [fromWeibo appendFormat:@"%@:%@",self.status.retweetedStatus.userWeiboInfo.name,self.status.retweetedStatus.weiboText];
        self.fromText.numberOfLines = 0;
        self.fromText.attributedText = [self filterLinkWithContent:fromWeibo];
        self.fromText.font = tfont;
        
        NSDictionary *tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
        CGSize fromTextSize = [fromWeibo boundingRectWithSize:MaxSize options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
        
        [self.fromView addSubview:self.fromText];
        self.fromText.frame = CGRectMake(0,8, fromTextSize.width, fromTextSize.height);
        self.fromView.frame = CGRectMake(8, self.content.frame.origin.y + self.content.frame.size.height + 8, self.view.frame.size.width - 2 * 8, self.fromText.frame.size.height+8);
        self.fromView.backgroundColor = [UIColor colorWithWhite:0.93 alpha:0.9];
    }
    
//    if (self.status.thumbnailPic.count) {
//        self.photoArray = [NSMutableArray array];
//        [self addPhoto:self.status.thumbnailPic andheight:self.content.frame.origin.y + _contentSize.height + 5];
//    }
}

-(void) addPhoto:(NSMutableArray *)array andheight:(CGFloat) CGPointY
{
    UIImageView *imageView = [[UIImageView alloc]init];
    for ( NSString *url in array) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [imageView setImageWithURLRequest:request placeholderImage:nil success:nil failure:nil];
        [self.photoArray addObject:imageView];
    }
    
    if (self.photoArray.count == 1) {
        [self.photoArray[0] setFrame:CGRectMake(10, CGPointY, 360,360)];
        [self.view addSubview:self.photoArray[0]];
    }
    else
    {
        for (int count = 0; count < self.photoArray.count; count++) {
            [self.photoArray[count] setFrame:CGRectMake(0, CGPointY + count * 30, 30,30)];
            [self.view addSubview:self.photoArray[count]];
            NSLog(@"%d",count);
        }
    }
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

//-(void)viewDidLayoutSubviews
//{
//    self.content.frame = CGRectMake(2 * kStart, kStart + self.headImage.frame.origin.y + self.headImage.frame.size.height, _contentSize.width, _contentSize.height);
//    
//    UIFont *tfont = [UIFont systemFontOfSize:14];
//    CGSize MaxSize = CGSizeMake(self.view.frame.size.width - 4 * kStart,0);
//    
//    NSMutableString *fromWeibo = [[NSMutableString alloc] initWithString:@"@"];
//    [fromWeibo appendFormat:@"%@:%@",self.status.retweetedStatus.userWeiboInfo.name,self.status.retweetedStatus.weiboText];
//    self.fromText.numberOfLines = 0;
//    self.fromText.attributedText = [self filterLinkWithContent:fromWeibo];
//    self.fromText.font = tfont;
//    
//    NSDictionary *tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
//    CGSize fromTextSize = [fromWeibo boundingRectWithSize:MaxSize options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
//    self.fromText.frame = CGRectMake(0,8, fromTextSize.width, fromTextSize.height);
//    
//    [self.fromView addSubview:self.fromText];
//    self.fromView.frame = CGRectMake(8, self.content.frame.origin.y + self.content.frame.size.height + 8, self.view.frame.size.width - 2 * 8, self.fromText.frame.size.height+8);
//    self.fromView.
//    self.fromView.backgroundColor = [UIColor colorWithWhite:0.93 alpha:0.9];
//}


@end
