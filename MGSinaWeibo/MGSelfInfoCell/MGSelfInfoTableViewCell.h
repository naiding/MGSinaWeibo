//
//  MGSelfInfoTableViewCell.h
//  
//
//  Created by LEON on 14/12/16.
//
//

#import <UIKit/UIKit.h>
#import "MGWeiboModel.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

@interface MGSelfInfoTableViewCell : UITableViewCell

@property (strong,nonatomic) User *me;

@property (weak, nonatomic) IBOutlet UIImageView *HeadImage;
@property (weak, nonatomic) IBOutlet UIImageView *BgImage;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *weibo;
@property (weak, nonatomic) IBOutlet UILabel *following;
@property (weak, nonatomic) IBOutlet UILabel *follower;
@property (weak, nonatomic) IBOutlet UILabel *profile;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blur;

- (IBAction)weiboBtn:(id)sender;
- (IBAction)followingBtn:(id)sender;
- (IBAction)followerBtn:(id)sender;

-(void) setSelfInfoCell:(User *)theUser;

@end
