//
//  FriendCell.h
//  LMeet
//
//  Created by Hicham Abou Jaoude on 1/18/2014.
//  Copyright (c) 2014 Hicham Abou Jaoude. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userStatus;
@property (weak, nonatomic) IBOutlet UIImageView *userPP;
@end
