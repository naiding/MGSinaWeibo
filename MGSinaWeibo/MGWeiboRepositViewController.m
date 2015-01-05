//
//  MGWeiboRepositViewController.m
//  MGSinaWeibo
//
//  Created by LEON on 15/1/3.
//  Copyright (c) 2015年 LEON. All rights reserved.
//

#import "MGWeiboRepositViewController.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"


@implementation MGWeiboRepositViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.repositText.delegate = self;
    
    self.repositText.textColor = [UIColor blackColor];
    self.repositText.font = [UIFont systemFontOfSize:16.0f];
    self.repositText.editable = YES;
    self.repositText.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.repositText.keyboardType = UIKeyboardTypeDefault;
    
    self.repositText.text = @"说说分享心得...";
    
    [self initText];
    
    [self changeLabelText];
    
    [self setFromView:self.fromView];
    
}

-(void) setFromView:(UIView *)fromView
{
    self.fromView.backgroundColor = [UIColor colorWithWhite:0.93 alpha:0.9];
    
    NSURLRequest *request;
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.status.userWeiboInfo.profileImageUrl]];
    [self.fromHeadImage setImageWithURLRequest:request placeholderImage:nil success:NULL failure:NULL];
    
    self.fromNameLabel.font = [UIFont systemFontOfSize:15.0];
    self.fromNameLabel.text = self.status.userWeiboInfo.name;
    
    self.fromContentLabel.numberOfLines = 2;
    self.fromContentLabel.font = [UIFont systemFontOfSize:12.0f];
    self.fromContentLabel.text = self.status.weiboText;
    
    [self.verifiedImage.layer setCornerRadius:CGRectGetHeight([self.verifiedImage.layer bounds]) / 2];
    self.verifiedImage.layer.masksToBounds = YES;
    self.fromNameLabel.text = [[self.status userWeiboInfo] screenName];
    if (self.status.userWeiboInfo.verified)
    {
        self.fromNameLabel.textColor = [UIColor redColor];
        self.verifiedImage.hidden = NO;
    }
    else
    {
        self.fromNameLabel.textColor = [UIColor blackColor];
        self.verifiedImage.hidden = YES;
    }
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)Send:(id)sender {
    
    if (self.repositText.text.length <= 140)
    {
        [MGSinaEngine repostStatusWithStatusId:self.status.statusId
                                       content:self.repositText.text
                                     isComment:0
                                       success:^(BOOL isSuccess, Status *aStatus)
        {
           
            if (isSuccess) {
                NSLog(@"yeah");
                [self.delegate didClickedDismissButton:YES];
            }
        }];
    }
    else
    {
        [self lockAnimationForView:self.inputState];
    }
}

#pragma text

-(void) initText
{
    if (self.status.retweetedStatus.weiboText)
    {
        NSString *string = [NSString stringWithFormat:@"//"];
        self.repositText.text = [string stringByAppendingString:self.status.weiboText];
        
        NSRange range;
        range.location = 0;
        range.length = 0;
        
        self.repositText.selectedRange = range;

        [self.repositText becomeFirstResponder];
    }
    else
    {
        self.repositText.text = @"说说分享心得...";
    }
    
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([textView isEqual:self.repositText]) {
        return YES;
    }
    return NO;
}

-(void) textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView isEqual:self.repositText]) {
        
        if (!self.status.retweetedStatus.weiboText)
        {
            self.repositText.text = @"";
        }
        
        [self changeLabelText];
    }
}

-(void) textViewDidChange:(UITextView *)textView
{
    
    if ([textView isEqual:self.repositText]) {
        self.repositText.font = [UIFont systemFontOfSize:16.0f];
        self.repositText.attributedText = [self filterLinkWithContent:self.repositText.text];
        [self changeLabelText];
    }
}

-(void) changeLabelText
{
    
    if (self.repositText.text.length <= 140 ) {
        self.inputState.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.repositText.text.length];
        self.inputState.textColor = [UIColor blackColor];
    }
    else
    {
        self.inputState.text = [NSString stringWithFormat:@"-%lu",(unsigned long)self.repositText.text.length- 140];
        self.inputState.textColor = [UIColor redColor];
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
    
    if (attributedString.length > 140) {
        
        //        NSDictionary *attrsDic = [NSDictionary dictionaryWithObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
        //
        //        [attributedString setAttributes:attrsDic range:NSMakeRange(140, attributedString.length - 140)];
        
        
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(140, attributedString.length - 140)];
    }
    if (attributedString.length > 0) {
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.0] range:NSMakeRange(0, attributedString.length - 1)];
    }
    
    return attributedString;
}

-(void)lockAnimationForView:(UIView*)view

{
    
    CALayer *lbl = [view layer];
    
    CGPoint posLbl = [lbl position];
    
    CGPoint y = CGPointMake(posLbl.x-5, posLbl.y);
    
    CGPoint x = CGPointMake(posLbl.x+5, posLbl.y);
    
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"position"];
    
    [animation setTimingFunction:[CAMediaTimingFunction
                                  
                                  functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [animation setFromValue:[NSValue valueWithCGPoint:x]];
    
    [animation setToValue:[NSValue valueWithCGPoint:y]];
    
    [animation setAutoreverses:YES];
    
    [animation setDuration:0.05];
    
    [animation setRepeatCount:3];
    
    [lbl addAnimation:animation forKey:nil];
    
}





@end
