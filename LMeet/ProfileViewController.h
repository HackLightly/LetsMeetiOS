//
//  ProfileViewController.h
//  LMeet
//
//  Created by Hicham Abou Jaoude on 1/18/2014.
//  Copyright (c) 2014 Hicham Abou Jaoude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocketIO.h"
#import "SocketIOJSONSerialization.h"
#import <MapKit/MapKit.h>
@interface ProfileViewController : UIViewController <SocketIODelegate>
{
    SocketIO *socketIO;
    NSMutableArray *friends;
    NSMutableArray *friendsID;
    NSMutableArray *myStatus;

    IBOutlet UITableView *tableView;
    
    IBOutlet MKMapView *mapView;
}

@end
