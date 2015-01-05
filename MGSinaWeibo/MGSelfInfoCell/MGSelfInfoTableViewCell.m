//
//  MGSelfInfoTableViewCell.m
//  
//
//  Created by LEON on 14/12/16.
//
//

#import "MGSelfInfoTableViewCell.h"

@implementation MGSelfInfoTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setSelfInfoCell:(User *)theUser
{
    //NSLog(@"%s", __FUNCTION__);
    NSURLRequest *request;
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:theUser.profileImageUrl]];
    [self.HeadImage setImageWithURLRequest:request placeholderImage:nil success:NULL failure:NULL];
    
    [self.HeadImage.layer setCornerRadius:CGRectGetHeight([self.HeadImage.layer bounds]) / 2];
    self.HeadImage.layer.masksToBounds = YES;
    
    self.HeadImage.layer.borderWidth = 2;
    self.HeadImage.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:theUser.coverImagePhoneUrl]];
    [self.BgImage setImageWithURLRequest:request placeholderImage:nil success:nil failure:nil];
    
    self.name.text = theUser.name;
    self.following.text = [NSString stringWithFormat:@"%d",theUser.friendsCount];
    self.follower.text = [NSString stringWithFormat:@"%d",theUser.followersCount];
    self.weibo.text = [NSString stringWithFormat:@"%d",theUser.statusesCount];
    self.profile.text = theUser.description;
    self.location.text = theUser.location;
}


- (IBAction)weiboBtn:(id)sender {
}

- (IBAction)followingBtn:(id)sender {
}

- (IBAction)followerBtn:(id)sender {
}
@end
