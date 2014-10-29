//
//  ChooseViewController.h
//  LMeet
//
//  Created by Hicham Abou Jaoude on 1/18/2014.
//  Copyright (c) 2014 Hicham Abou Jaoude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocketIO.h"
@interface ChooseViewController : UIViewController
{
    SocketIO *socketIO;
    IBOutlet UITableView *tableView;
    NSMutableArray *friends;
    NSMutableArray *friendsID;
    NSMutableArray *friendsPP;
    NSMutableArray *arr_fortable;
  IBOutlet NSMutableArray *chatFriends;
  IBOutlet NSMutableArray *chatFriendsID;
IBOutlet NSMutableArray *chatFriendsPP;
}

@property (strong, nonatomic) IBOutlet NSMutableArray *myStatus;

@end
