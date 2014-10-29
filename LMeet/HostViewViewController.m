//
//  HostViewViewController.m
//  LMeet
//
//  Created by Hicham Abou Jaoude on 1/18/2014.
//  Copyright (c) 2014 Hicham Abou Jaoude. All rights reserved.
//

#import "HostViewViewController.h"
#import "SocketIOPacket.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "ChatCell.h"
#import <MapKit/MapKit.h>
#import "Annotation.h"
@interface HostViewViewController () <MKMapViewDelegate>

@end

@implementation HostViewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void) socketIODidConnect:(SocketIO *)socket
{
    NSLog(@"socket.io connected.");
}
-(CLLocationCoordinate2D) getLocation{
    CLLocationManager *locationManager = [[CLLocationManager alloc] init] ;
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    return coordinate;
}
-(void)uploadLocation
{
  NSLog(@"Uploadin...");
 FBRequest *request = [FBRequest requestForMe];
    PFUser *current = [PFUser currentUser];
    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSLog(@"workeds");
            NSDictionary *userData = (NSDictionary *)result;
            NSString *facebookID = userData[@"id"];
    CLLocationCoordinate2D coordinate = [self getLocation];
    double latitude =  coordinate.latitude;
    double longitude = coordinate.longitude;
            NSString *string = [NSString stringWithFormat:@"%@ %g %g",facebookID,latitude,longitude ];
    [socketIO sendEvent:@"send_location" withData:string];
     }}];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    if ([text rangeOfString:@"\n"].location != NSNotFound) {
        NSString *message = [[textView.text stringByReplacingCharactersInRange:range withString:text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
         PFUser *current = [PFUser currentUser];
        NSString *name = [current objectForKey:@"name"]; // Get UserName
        [messages addObject:message];
        [fromAr addObject:name];
        // Insert send message and user.
        //
      
        FBRequest *request = [FBRequest requestForMe];
            // Send request to Facebook
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                // result is a dictionary with the user's Facebook data
                  NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                NSLog(@"workeds");
                NSDictionary *userData = (NSDictionary *)result;
                NSString *facebookID = userData[@"id"];

        [dict setValue:message forKey:@"message"];
        [dict setValue:facebookID forKey:@"username"];
                [socketIO sendEvent:@"send_message" withData:dict];
            }}];
        
         [tableView scrollRectToVisible:CGRectMake(0, tableView.contentSize.height - tableView.bounds.size.height, tableView.bounds.size.width, tableView.bounds.size.height+72) animated:YES];
        //
        ////////////////////////////////
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow: messages.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [tableView scrollRectToVisible:tableView.tableFooterView.frame animated:YES];
        textView.text = @"";
        return NO;
    }
    return YES;
}

-(IBAction)meetUp:(id)sender
{
    NSMutableArray *locationCoord = [[NSMutableArray alloc] init];
    NSMutableArray *locationName = [[NSMutableArray alloc] init];
    if (longit && latit)
    {
       locationCoord = [[NSMutableArray alloc] initWithObjects:latit,longit, nil];
        locationName = [[NSMutableArray alloc] initWithObjects:@"Midpoint", nil];
    }
    [[NSUserDefaults standardUserDefaults] setObject:locationName forKey:@"locName"];
    [[NSUserDefaults standardUserDefaults] setObject:locationCoord forKey:@"locCord"];
    [self performSegueWithIdentifier:@"goBack" sender:self];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
    if ([self.create isEqualToString:@"yes"])
    {
        meetButton.alpha = 1;
        meetButton.enabled = YES;
    }
    socketIO = [[SocketIO alloc] initWithDelegate:self];
    [socketIO connectToHost:@"vast-woodland-7556.herokuapp.com" onPort:0];
    NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(uploadLocation) userInfo:nil repeats:YES];
    [self uploadLocation];
    MKCoordinateRegion region;
    region.center = mapView.userLocation.location.coordinate;
    region.span = MKCoordinateSpanMake(0.2, 0.2); //Zoom distance
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
    
}

-(void)viewDidLayoutSubviews {
    
    [scrollView setScrollEnabled:YES];

    scrollView.contentSize = CGSizeMake(320, 1140);
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    FBRequest *request = [FBRequest requestForMe];
    PFUser *current = [PFUser currentUser];
    // Send request to Facebook
     NSLog(@"@@@@@@@%@", packet.name);
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSLog(@"workeds");
            NSDictionary *userData = (NSDictionary *)result;
            NSString *facebookID = userData[@"id"];
            NSLog(@"didReceiveEvent()");
            
            SocketIOCallback cb = ^(id argsData) {
                NSDictionary *response = argsData;
                NSLog(@"ack arrived: %@", response);
                
                [socketIO disconnectForced];
            };
            if ([packet.name isEqualToString:@"connected" ]) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                [dict setValue:facebookID forKey:@"username"];
                [socketIO sendEvent:@"register" withData:dict];
                sleep(0.5);
                
                NSLog(@"%@It z is", self.create);
                if ([self.create isEqualToString:@"yes"])
                {
                FBRequest *request = [FBRequest requestForMe];
                PFUser *current = [PFUser currentUser];
                // Send request to Facebook
                [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    if (!error) {
                        // result is a dictionary with the user's Facebook data
                        NSLog(@"workeds");
                        NSDictionary *userData = (NSDictionary *)result;
                        NSString *facebookID = userData[@"id"];
                        NSLog(@"They are not");
                        NSLog(@"They are equal");
                        NSArray *users = [NSArray arrayWithArray:self.chatFriendID];
                        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:users forKey:@"username"];
                        //NSLog(@"Array is: %@",users);
                        [dict setValue:facebookID forKey:@"hostname"];
                        [socketIO sendEvent:@"create_meetup" withData:dict];
                    }
                }
                 ];
                }else {
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setValue:self.hostID forKey:@"meetup_id"];
                    [socketIO sendEvent:@"join" withData:dict];
                }
                }
            // Recieve Messages (make sure to use these ( [messages addObject:message]; and [fromAr addObject:name]; ) to add the messages to the tableview.
            //
            if ([packet.name isEqualToString:@"message" ]) {
                
                NSLog(@"%@",packet.args[0]);
               
                NSArray *temp = [packet.args[0] componentsSeparatedByString:@" "];
                NSMutableString *tempString = [[NSMutableString alloc] init];
                for (int i = 1; i < temp.count; i++) {
                    [tempString appendString:[temp objectAtIndex:i]];
                    [tempString appendString:@" "];
                }
                [messages addObject:tempString];
                [fromAr addObject:temp[0]];
                [tableView reloadData];
                [tableView scrollRectToVisible:CGRectMake(0, tableView.contentSize.height - tableView.bounds.size.height, tableView.bounds.size.width, tableView.bounds.size.height+72) animated:YES];
                NSLog(@"Count is :%i",messages.count);
            }
            if ([packet.name isEqualToString:@"location" ]) {
                NSLog(@"LOOOOOCATION");
                NSLog(@"%@",packet.args[0]);
                NSArray *temp = [packet.args[0] componentsSeparatedByString:@" "];
                NSMutableString *tempString = [[NSMutableString alloc] init];
                for (int i = 1; i < temp.count; i++) {
                    [tempString appendString:[temp objectAtIndex:i]];
                    [tempString appendString:@" "];
                }
                if ([locationArray containsObject:[temp objectAtIndex:0]])
                {
                    [coordArray replaceObjectAtIndex:[locationArray indexOfObject:[temp objectAtIndex:0]] withObject:[[NSMutableArray alloc] initWithObjects:[temp objectAtIndex:1], [temp objectAtIndex:2],nil]];
                } else {
                    [locationArray addObject:[temp objectAtIndex:0]];
                    NSMutableArray *mutAr = [[NSMutableArray alloc] initWithObjects:[temp objectAtIndex:1],[temp objectAtIndex:2],nil];
                    [coordArray addObject:mutAr];
                }
               
                FBRequest *friendsRequest =  [FBRequest  requestWithGraphPath:@"me/friends"
                                                                   parameters:@{@"fields":@"name,installed,first_name"}
                                                                   HTTPMethod:@"GET"];
                
                [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                              NSDictionary* result,
                                                              NSError *error) {
                    NSArray *friendObj = [result objectForKey:@"data"];
                   
                    CLLocationCoordinate2D location;
                    // Add the annotation to our map view
                    
                    NSMutableArray *friends = [[NSMutableArray alloc]init];
                    NSMutableArray *friendsID = [[NSMutableArray alloc]init];
                    for (NSDictionary<FBGraphUser>* friend in friendObj) {
                        if ([friend objectForKey:@"installed"] ){
                            NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
                            [friends addObject:friend.name];
                            [friendsID addObject:friend.id];
                        }
                        
                    }
                    NSLog(@"QWEERTTWER%d, %d",friendsID.count,locationArray.count);
                    Annotation *newAnnotation = [[Annotation alloc]init];
                    for (int x = 0; x<friendsID.count; x++)
                    {
                        for (int y = 0; y<locationArray.count;y++){
                            NSLog(@"%d, %d",x,y);
                            if ([[locationArray objectAtIndex:y] isEqualToString:[friendsID objectAtIndex:x]])
                            {
                                NSLog(@"goes inside if");
                                newAnnotation.title = [friends objectAtIndex:x];
                                location.latitude = (double) [[[coordArray objectAtIndex:y] objectAtIndex:0] doubleValue];
                                location.longitude = (double) [[[coordArray objectAtIndex:y] objectAtIndex:1] doubleValue];
                                newAnnotation.coordinate = location;
                                [mapView addAnnotation:newAnnotation];
                                NSLog(@"leaves if");
                            }
                        }
                        
                    }
                }];
               
                if ([self.create isEqualToString:@"yes"])
                {
                    
                    NSMutableArray *qwerty = [[NSMutableArray alloc]init];
                    //float qwerty[(coordArray.count+1)*2];
                    
                     CLLocationCoordinate2D coordinate = [self getLocation];
                    [qwerty addObject:[NSString stringWithFormat:@"%f",coordinate.latitude]];
                    [qwerty addObject:[NSString stringWithFormat:@"%f",coordinate.longitude]];
                     NSLog(@"COUNT%d",coordArray.count);
                    for (int i = 0; i < coordArray.count; i++) {
                        
                        
                     //   qwerty[i+1] = [[[coordArray objectAtIndex:i] objectAtIndex:0] doubleValue];
                     //   qwerty[i+2] = [[[coordArray objectAtIndex:i] objectAtIndex:1] doubleValue];
                        [qwerty addObject:[[coordArray objectAtIndex:i] objectAtIndex:0]];
                
                           [qwerty addObject:[[coordArray objectAtIndex:i] objectAtIndex:1]];
                    }
                    
                    for (int i = 0; i < qwerty.count; i++) {
                        NSLog(@"WTFMAN%@",[qwerty objectAtIndex:i]);
                    }

                    //NSArray *qwertyu = [[NSArray alloc] initWithArray:qwerty];
                     NSLog(@"GOES INSIDE MIDPOINT SEND");
                [PFCloud callFunctionInBackground:@"getMidPoint"
                                       withParameters:@{@"points": qwerty}
                                                block:^(PFObject *eventObj, NSError *error) {
                                                    NSLog(@"%@",[error localizedDescription]);
                                                    if (!error) {
                                                        NSLog(@"Uploadin...!");
                                                        FBRequest *request = [FBRequest requestForMe];
                                                        PFUser *current = [PFUser currentUser];
                                                        // Send request to Facebook
                                                        //if (coordArray != NULL)
                                                        //NSLog(@"LATLONG %@ %@",[coordArray objectAtIndex:0], [coordArray objectAtIndex:1]);
                                                        NSLog(@"check...!");
                                                        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                                            NSLog(@"wut");
                                                            
                                                            if (!error) {
                                                                NSLog(@"wat");
                                                                NSString *temp0 = eventObj ;
                                                                
                                                                NSLog(@"%@",temp0);
                                                                double myLat = [[[temp0 componentsSeparatedByString:@","] objectAtIndex:0]doubleValue];
                                                                double myLon =[[[temp0 componentsSeparatedByString:@","] objectAtIndex:1]doubleValue];
                                                              NSLog(@"MIDPOINT%g %g",myLat,myLon);
                                                                NSString *string = [NSString stringWithFormat:@"%g %g",myLat,myLon ];
                                                                [socketIO sendEvent:@"send_midpoint" withData:string];
                                                                
                                                            }}];

                                                    }}];
                }
            }
        
                if ([packet.name isEqualToString:@"midpoint"]) {
                     NSLog(@"GOES INSIDE MIDPOINT RECIEVED");
                    NSArray *temp = [packet.args[0] componentsSeparatedByString:@" "];
                    NSMutableString *tempString = [[NSMutableString alloc] init];
                    for (int i = 1; i < temp.count; i++) {
                        [tempString appendString:[temp objectAtIndex:i]];
                        [tempString appendString:@" "];
                    }
                    CLLocationCoordinate2D location;
                    Annotation *newAnnotation = [[Annotation alloc]init];
                    newAnnotation.title = @"Midpoint";
                    location.latitude = [[temp objectAtIndex:0] doubleValue];
                    location.longitude = [[temp objectAtIndex:1] doubleValue];
                    longit = [NSString stringWithFormat:@"%g", [[temp objectAtIndex:1]doubleValue]];
                    latit =  [NSString stringWithFormat:@"%g", [[temp objectAtIndex:0]doubleValue]];
                    newAnnotation.coordinate = location;
                    [mapView addAnnotation:newAnnotation];
                }
            }
    }];
}
NSString *longit=@"0", *latit=@"0",*locName=@"";
-(IBAction)endsess
{
    
}

- (void)tableView:(UITableView *)tripsTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIKeyboardWillShowNotification object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIKeyboardDidShowNotification object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIKeyboardWillHideNotification object: nil];
}
- (void) keyboardWillShow: (NSNotification*) aNotification
{
    [UIView animateWithDuration: [self keyboardAnimationDurationForNotification: aNotification] animations:^{
        CGSize kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        //change the frame of your talbleiview via kbsize.height
    } completion:^(BOOL finished) {
    }];
}

- (void) keyboardDidShow: (NSNotification*) aNotification
{
    [UIView animateWithDuration: [self keyboardAnimationDurationForNotification: aNotification] animations:^{
        CGSize kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        tableView.frame = CGRectMake(0, 637, 320, 283);
    } completion:^(BOOL finished) {
    }];
}

- (void) keyboardWillDisappear: (NSNotification*) aNotification
{
    [UIView animateWithDuration: [self keyboardAnimationDurationForNotification: aNotification] animations:^{
        tableView.frame = CGRectMake(0, 637, 320, 499);
    } completion:^(BOOL finished) {
    }];
}

- (NSTimeInterval) keyboardAnimationDurationForNotification:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    NSValue* value = [info objectForKey: UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration = 0;
    [value getValue: &duration];
    
    return duration;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //[self checkPeople];
    
    return messages.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"chatcell";
    ChatCell *cell = [[ChatCell alloc]init];
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textView.text = [messages objectAtIndex:indexPath.row];
    cell.nameLabel.text = [fromAr objectAtIndex:indexPath.row];
    return cell;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [socketIO disconnectForced];
}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error
{
    NSLog(@"onError() %@", error);
}


- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    NSLog(@"socket.io disconnected. did error occur? %@", error);
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    messages = [[NSMutableArray alloc] init];
    fromAr = [[NSMutableArray alloc] init];
    coordArray = [[NSMutableArray alloc] init];
    locationArray = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillShow:)
                                                 name: UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardDidShow:)
                                                 name: UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillDisappear:)
                                                 name: UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
