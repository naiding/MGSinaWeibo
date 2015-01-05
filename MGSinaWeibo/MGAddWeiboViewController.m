//
//  MGAddWeiboViewController.m
//  MGSinaWeibo
//
//  Created by LEON on 14/12/18.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import "MGAddWeiboViewController.h"

@interface MGAddWeiboViewController ()<UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

- (IBAction)sendWeibo:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *weiboText;
@property (strong, nonatomic) IBOutlet UILabel *inputState;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) NSMutableArray *photoArray;

@end

@implementation MGAddWeiboViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    self.weiboText.delegate = self;
    
    self.weiboText.textColor = [UIColor blackColor];
    self.weiboText.font = [UIFont systemFontOfSize:16.0f];
    self.weiboText.editable = YES;
    self.weiboText.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.weiboText.keyboardType = UIKeyboardTypeDefault;
    self.weiboText.delegate = self;

    
    [self initText];
    
    if (!self.photoArray) {
        self.photoArray = [NSMutableArray array];
    }

    [self initPhoto];
    
    [self changeLabelText];

    
    self.imagePicker = [UIImagePickerController new];
    //imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    self.imagePicker.delegate = self;

}

#pragma text

-(void) initText
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"SINA_TEXT_WAITING_TO_SEND"])
    {
        self.weiboText.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"SINA_TEXT_WAITING_TO_SEND"];
    }
    if (!([[NSUserDefaults standardUserDefaults]objectForKey:@"SINA_TEXT_WAITING_TO_SEND"] ||
          [[NSUserDefaults standardUserDefaults] objectForKey:@"SINA_PHOTO_ARRAY_WAITING_TO_SEND"]))
    {
        self.weiboText.text = @"分享新鲜事...";
    }
}

-(void) initPhoto
{
    if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"SINA_PHOTO_ARRAY_WAITING_TO_SEND"]) {
        NSMutableArray *array =  [[NSUserDefaults standardUserDefaults] objectForKey:@"SINA_PHOTO_ARRAY_WAITING_TO_SEND"];
        UIImage *image = [[UIImage alloc]init];
        
        [self.photoArray removeAllObjects];
        for (NSData *data in array) {
            image = [UIImage imageWithData:data];
            [self.photoArray addObject:image];
        }
        [self addphotoArrayToView];
    }
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([textView isEqual:self.weiboText]) {
        return YES;
    }
    return NO;
}

-(void) textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView isEqual:self.weiboText]) {
        
        if (!([[NSUserDefaults standardUserDefaults]objectForKey:@"SINA_TEXT_WAITING_TO_SEND"] ||
              [[NSUserDefaults standardUserDefaults] objectForKey:@"SINA_PHOTO_ARRAY_WAITING_TO_SEND"]))
        {
            self.weiboText.text = @"";
            
        }
        
        [self changeLabelText];
    }
}

-(void) textViewDidChange:(UITextView *)textView
{
    
    if ([textView isEqual:self.weiboText]) {
        self.weiboText.font = [UIFont systemFontOfSize:16.0f];
        self.weiboText.attributedText = [self filterLinkWithContent:self.weiboText.text];
        [self changeLabelText];
    }
}

-(void) changeLabelText
{
    
    if (self.weiboText.text.length <= 140 ) {
        self.inputState.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.weiboText.text.length];
        self.inputState.textColor = [UIColor blackColor];
    }
    else
    {
        self.inputState.text = [NSString stringWithFormat:@"-%lu",(unsigned long)self.weiboText.text.length- 140];
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



-(void) addphotoArrayToView
{
    if (self.photoArray.count) {
        for (int count = 0; count < self.photoArray.count; count++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.weiboText.frame.origin.x + 5 * (count + 1) + count * 50, self.weiboText.frame.origin.y + self.weiboText.frame.size.height - 50, 50 , 50)];
            
            imageView.image = self.photoArray[count];
            [self.view addSubview:imageView];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    if (self.photoArray.count) {
        for (UIImage *image in self.photoArray) {
            NSData *data = UIImagePNGRepresentation(image);
            [array addObject:data];
        }
    }
    
    [self.delegate saveDraft:self.weiboText.text andPhotoArray:array];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (!self.photoArray) {
        self.photoArray = [NSMutableArray array];
    }
    
    [self.photoArray addObject:info[UIImagePickerControllerOriginalImage]];
    [self addphotoArrayToView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)sendWeibo:(id)sender {
    
    NSData *data = [[NSData alloc]init];
    
    if(self.photoArray.count > 0)
    {
        data = UIImagePNGRepresentation(self.photoArray[0]);
    }
    else
    {
        data = nil;
    }
    
    if (self.weiboText.text.length <= 140) {
        [MGSinaEngine sendStatus:self.weiboText.text
                         picData:data
                        latFloat:+39.9
                       longFloat:+116.38
                         visible:0
                          listId:nil
                         success:^(BOOL isSuccess, Status *aStatus)
         {
             if (isSuccess) {
                 if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedDismissButton:)]) {
                     [self.delegate didClickedDismissButton:YES];
                 }
                 
             }else if (!isSuccess)
             {
                 if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedDismissButton:)]) {
                     [self.delegate didClickedDismissButton:NO];
                 }
             }
         }];

    }
    else
    {
        [self lockAnimationForView:self.inputState];
    }
    
}

- (void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];
}

- (void) keyboardWasShown:(NSNotification *) notif
{
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    
    NSLog(@"keyBoard:%f", keyboardSize.height);  //216
    ///keyboardWasShown = YES;
}
- (void) keyboardWasHidden:(NSNotification *) notif
{
    NSDictionary *info = [notif userInfo];
    
    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    NSLog(@"keyboardWasHidden keyBoard:%f", keyboardSize.height);
    // keyboardWasShown = NO;
    
}


- (IBAction)getPhoto:(id)sender {
    
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}
@end
