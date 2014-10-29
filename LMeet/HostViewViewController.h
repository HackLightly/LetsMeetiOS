//
//  HostViewViewController.h
//  LMeet
//
//  Created by Hicham Abou Jaoude on 1/18/2014.
//  Copyright (c) 2014 Hicham Abou Jaoude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocketIO.h"
#import <MapKit/MapKit.h>
@interface HostViewViewController : UIViewController

{
    SocketIO *socketIO;
    IBOutlet UIButton *meetButton;
    IBOutlet NSMutableArray *messages;
    IBOutlet NSMutableArray *fromAr;
    IBOutlet NSMutableArray *nameAr;
    IBOutlet UITableView *tableView;
    IBOutlet UIScrollView *scrollView;
    IBOutlet MKMapView *mapView;
     NSMutableArray *locationArray;
    NSMutableArray *coordArray;
    NSMutableArray *coordArray2;
    IBOutlet UIToolbar *accessView;
    
}
@property (strong, nonatomic) IBOutlet NSMutableArray *chatFriend;
@property (strong, nonatomic) IBOutlet NSMutableArray *chatFriendID;
@property (strong, nonatomic) IBOutlet NSMutableArray *chatFriendPP;
@property (strong, nonatomic) NSString *create;
@property (strong, nonatomic) NSString *hostID;
@property (nonatomic, retain) IBOutlet UITextView *inputView;
@property (nonatomic, strong) HostViewViewController * hostView;
@end
