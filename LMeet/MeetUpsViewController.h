//
//  MeetUpsViewController.h
//  LMeet
//
//  Created by Hicham Abou Jaoude on 1/19/2014.
//  Copyright (c) 2014 Hicham Abou Jaoude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface MeetUpsViewController : UIViewController
{
    NSMutableArray *locName;
    NSMutableArray *locCoord;
    IBOutlet MKMapView *mapView;
    IBOutlet UITableView *tableView;
}

@end
