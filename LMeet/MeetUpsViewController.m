//
//  MeetUpsViewController.m
//  LMeet
//
//  Created by Hicham Abou Jaoude on 1/19/2014.
//  Copyright (c) 2014 Hicham Abou Jaoude. All rights reserved.
//

#import "MeetUpsViewController.h"
#import "FriendCell.h"
#import "Annotation.h"
@interface MeetUpsViewController ()

@end

@implementation MeetUpsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    locName = [[NSUserDefaults standardUserDefaults] objectForKey:@"locName"];
    locCoord = [[NSUserDefaults standardUserDefaults] objectForKey:@"locCord"];
	// Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [tableView reloadData];
   
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)tableView:(UITableView *)tripsTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //[self checkPeople];
    locName = [[NSUserDefaults standardUserDefaults] objectForKey:@"locName"];
    NSLog(@"%d loc count",locName.count);
    return locName.count;
    
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
        static NSString *CellIdentifier = @"cell";
        FriendCell *cell = [[FriendCell alloc]init];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.userName.text = @"Midpoint";
        CLLocationCoordinate2D location;
        Annotation *newAnnotation = [[Annotation alloc]init];
        newAnnotation.title = @"Midpoint";
        location.latitude = (double) [[locCoord objectAtIndex:0] doubleValue];
        location.longitude = (double) [[locCoord objectAtIndex:1] doubleValue];
        newAnnotation.coordinate = location;
        [mapView addAnnotation:newAnnotation];
        MKCoordinateRegion region;
        region.center = location;
        region.span = MKCoordinateSpanMake(0.2, 0.2); //Zoom distance
        region = [mapView regionThatFits:region];
        [mapView setRegion:region animated:YES];
        return cell;
}

@end
