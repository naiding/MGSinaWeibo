//
//  MGLoginViewController.m
//  MGSinaWeibo
//
//  Created by LEON on 14/12/10.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import "MGLoginViewController.h"
#import "MGWeiboModel.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"


static const CGFloat ThrowingThreshold = 1000;
static const CGFloat ThrowingVelocityPadding = 35;


@implementation MGLoginViewController

@synthesize completionHandler = _completionHandler;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.originalBounds = self.Weibo.bounds;
    self.originalCenter = self.Weibo.center;
    
    self.customNavBar = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
    self.customNavBar.backgroundColor = [UIColor blackColor];
    

}

- (void)viewWillAppear:(BOOL)animated {
    // all settings are basic, pages with custom packgrounds, title image on each page
    if ([MGSinaEngine isAuthorized]) {
        [self.loginBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        [self goToHomePage];
    }
    else
    {
        [self showIntroWithCrossDissolve];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Login:(id)sender
{
    if (![MGSinaEngine isAuthorized])
    {
        [self startRequest];
    }
    else
    {
        [self goToHomePage];
    }
}

- (id)initWithLoginCompletion:(void (^) (BOOL isLoginSuccess))isLoginSuccess
{
    if (self = [super init]) {
        self.completionHandler = isLoginSuccess;
    }
    return self;
}

#pragma mark -
#pragma mark 请求网络

-(void)startRequest
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    //自定义导航
    [self.view addSubview:self.customNavBar];
    
    UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [returnBtn setTitle:@"取消" forState:UIControlStateNormal];
    returnBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    returnBtn.frame = CGRectMake(7, 7, 50, 30);
    [returnBtn addTarget:self action:@selector(Cancelbtn) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavBar addSubview:returnBtn];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,64,self.view.frame.size.width,self.view.frame.size.height- 64)];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[MGSinaEngine authorizeURL]];
    [_webView loadRequest:request];
}

-(void)Cancelbtn
{
    _webView.delegate = nil;
    [_webView removeFromSuperview];
    if(self.completionHandler)
    {
        self.completionHandler(NO);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.customNavBar removeFromSuperview];
}


-(void) goToHomePage
{
    UITabBarController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"MGWeiboTabBarController"];
    
    
    
    [self presentViewController:home animated:YES completion:nil];
}


#pragma mark -
#pragma mark UIWebView代理方法

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString rangeOfString:@"code="].location != NSNotFound) {
        NSString *code = [[request.URL.query componentsSeparatedByString:@"="] objectAtIndex:1];
        
        NSString *codeURLstr = [[NSString alloc] initWithFormat:@"%@?client_id=%@&client_secret=%@&grant_type=authorization_code&redirect_uri=%@&code=%@",SINA_ACCESSTOKEN_URL,SINA_APP_KEY,SINA_APP_SECRET,SINA_REDIRECT_URI,code];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager POST:codeURLstr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

            
            NSData *doubi = responseObject;
            //json解析
            NSError *error;
            NSDictionary *userDic = [NSJSONSerialization JSONObjectWithData:doubi options:NSJSONReadingMutableLeaves error:&error];
            [MGSinaEngine saveLoginInfo:userDic];
            
            [MGSinaEngine getUserInfo:[userDic objectForKey:@"uid"] success:^(BOOL isSuccess, User *aUser)
             {
                 if (isSuccess) {
                     UIImageView *headImage;
                     UIImageView *bgImage;
                     NSData *data;
                     NSURLRequest *request;
                     
                     request = [NSURLRequest requestWithURL:[NSURL URLWithString:aUser.profileImageUrl]];
                     [headImage setImageWithURLRequest:request placeholderImage:nil success:NULL failure:NULL];
                     data = UIImagePNGRepresentation(headImage.image);
                     [[NSUserDefaults standardUserDefaults]setObject:data forKey:SINA_USER_HEAD_IMAGE];
                     
                     request = [NSURLRequest requestWithURL:[NSURL URLWithString:aUser.coverImagePhoneUrl]];
                     [bgImage setImageWithURLRequest:request placeholderImage:nil success:nil failure:nil];
                     data = UIImagePNGRepresentation(bgImage.image);
                     [[NSUserDefaults standardUserDefaults]setObject:data forKey:SINA_USER_BACKGROUND_IMAGE];
                     
                     [[NSUserDefaults standardUserDefaults]setObject:aUser.name forKey:SINA_USER_NAME];
                     [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",aUser.friendsCount]forKey:SINA_USER_FOLLOWING_COUNT];
                     [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%d",aUser.followersCount] forKey:SINA_USER_FOLLOWER_COUNT];
                     [[NSUserDefaults standardUserDefaults]setObject: [NSString stringWithFormat:@"%d",aUser.statusesCount] forKey:SINA_USER_STATUS_COUNT];
                     [[NSUserDefaults standardUserDefaults]setObject:aUser.description forKey:SINA_USER_DESCRIPTION];
                     [[NSUserDefaults standardUserDefaults]setObject:aUser.location forKey:SINA_USER_LOCATION];
                     
                     [[NSUserDefaults standardUserDefaults]synchronize];
                     
                      [self goToHomePage];
                 }
             }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark Introdduction

- (void)showIntroWithCrossDissolve {
    MGIntroPage *page1 = [MGIntroPage page];
    page1.title = @"Hello weibo";
    page1.desc = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    page1.bgImage = [UIImage imageNamed:@"1"];
    page1.titleImage = [UIImage imageNamed:@"original"];
    
    MGIntroPage *page2 = [MGIntroPage page];
    page2.title = @"Hello weibo";
    page2.desc = @"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore.";
    page2.bgImage = [UIImage imageNamed:@"2"];
    page2.titleImage = [UIImage imageNamed:@"supportcat"];
    
    MGIntroPage *page3 = [MGIntroPage page];
    page3.title = @"Hello weibo";
    page3.desc = @"Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.";
    page3.bgImage = [UIImage imageNamed:@"3"];
    page3.titleImage = [UIImage imageNamed:@"femalecodertocat"];
    
    MGIntroView *intro = [[MGIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3]];
    
    [intro setDelegate:self];
    [intro showInView:self.view animateDuration:0.0];
}

- (void)introDidFinish {
    NSLog(@"Intro callback");
}


#pragma mark -
#pragma mark Animation

- (IBAction) handleAttachmentGesture:(UIPanGestureRecognizer*)gesture
{
    CGPoint location = [gesture locationInView:self.view];
    CGPoint boxLocation = [gesture locationInView:self.Weibo];
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{
            // 1
            [self.animator removeAllBehaviors];
            
            // 2
            UIOffset centerOffset = UIOffsetMake(boxLocation.x - CGRectGetMidX(self.Weibo.bounds),
                                                 boxLocation.y - CGRectGetMidY(self.Weibo.bounds));
            self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.Weibo
                                                                offsetFromCenter:centerOffset
                                                                attachedToAnchor:location];
            
            [self.animator addBehavior:self.attachmentBehavior];
            
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self.animator removeBehavior:self.attachmentBehavior];
            
            //1
            CGPoint velocity = [gesture velocityInView:self.view];
            CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
            
            if (magnitude > ThrowingThreshold) {
                //2
                UIPushBehavior *pushBehavior = [[UIPushBehavior alloc]
                                                initWithItems:@[self.Weibo]
                                                mode:UIPushBehaviorModeInstantaneous];
                pushBehavior.pushDirection = CGVectorMake((velocity.x / 10) , (velocity.y / 10));
                pushBehavior.magnitude = magnitude / ThrowingVelocityPadding;
                
                self.pushBehavior = pushBehavior;
                [self.animator addBehavior:self.pushBehavior];
                
                //3
                NSInteger angle = arc4random_uniform(20) - 10;
                
                self.itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.Weibo]];
                self.itemBehavior.friction = 0.2;
                self.itemBehavior.allowsRotation = YES;
                [self.itemBehavior addAngularVelocity:angle forItem:self.Weibo];
                [self.animator addBehavior:self.itemBehavior];
                
                //4
                [self performSelector:@selector(resetDemo) withObject:nil afterDelay:0.4];
            }
            
            else {
                [self resetDemo];
            }
            
            break;
        }
        default:
            [self.attachmentBehavior setAnchorPoint:[gesture locationInView:self.view]];
            break;
    }
}

- (void)resetDemo
{
    [self.animator removeAllBehaviors];
    
    [UIView animateWithDuration:0.45 animations:^{
        self.Weibo.bounds = self.originalBounds;
        self.Weibo.center = self.originalCenter;
        self.Weibo.transform = CGAffineTransformIdentity;
    }];
}


@end
