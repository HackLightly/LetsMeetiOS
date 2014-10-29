//
//  ProfileViewController.m
//  LMeet
//
//  Created by Hicham Abou Jaoude on 1/18/2014.
//  Copyright (c) 2014 Hicham Abou Jaoude. All rights reserved.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "FriendCell.h"
#import "SocketIOPacket.h"
#import "ChooseViewController.h"
#import "HostViewViewController.h"
@interface ProfileViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userCity;


@end

@implementation ProfileViewController

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

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
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
            }
            if ([packet.name isEqualToString:@"user_status_string"]) {
                NSArray *temp = [packet.args[0] componentsSeparatedByString:@" "];
                myStatus = [[NSMutableArray alloc] init];
                for (int i = 0; i < temp.count; i++) {
                    
                    [myStatus addObject:[[NSArray alloc] initWithObjects: [temp objectAtIndex:i],[temp objectAtIndex:++i], nil]];
                    
                }
                
            }
            
            if ([packet.name isEqualToString:@"invite"]) {
                
                NSLog(@"Invite::: %@",packet.args[0]);
                NSArray *temp = [packet.args[0] componentsSeparatedByString:@" "];
                NSMutableString *tempString = [[NSMutableString alloc] init];
                for (int i = 1; i < temp.count; i++) {
                    [tempString appendString:[temp objectAtIndex:i]];
                    [tempString appendString:@" "];
                }
                hostID = [temp objectAtIndex:0];
                int c = 0;
                for (int x = 1; x<temp.count; x++)
                {
                    
                    
                    FBRequest *request = [FBRequest requestForMe];
                    PFUser *current = [PFUser currentUser];
                    // Send request to Facebook
                    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                        if (!error) {
                            
                    NSString *facebookID = userData[@"id"];
                    if ([facebookID isEqualToString:[temp objectAtIndex:x]]){
                        NSString *name = @"s";
                        for (int c = 0; c<friendsID.count; c++)
                        {
                            if ([[friendsID objectAtIndex:c] isEqualToString:[temp objectAtIndex:0]])
                            {
                                name = [friends objectAtIndex:c];
                                break;
                            }
                        }
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Join Meet Up" message:[NSString stringWithFormat:@"%@ would like to add you to his Meet Up",name] delegate:self cancelButtonTitle:@"Decline" otherButtonTitles:@"Join", nil];
                        [alertView show];
                    }
                        
                        }
                    }];
                    
                }
                
                
            }

        }
    
        
    }];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
      NSString *btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([btnTitle isEqualToString:@"Join"]) {
        [self performSegueWithIdentifier:@"toHost" sender:self];
    }
    // else do your stuff for the rest of the buttons (firstOtherButtonIndex, secondOtherButtonIndex, etc)
}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error
{
    NSLog(@"onError() %@", error);
}


- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    NSLog(@"socket.io disconnected. did error occur? %@", error);
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toHost"]) {
        [[segue destinationViewController] setCreate:@"no"];
         [[segue destinationViewController] setHostID:hostID];
        [socketIO disconnectForced];
    }
    if ([[segue identifier] isEqualToString:@"toSet"]) {
         [[segue destinationViewController] setMyStatus:myStatus];
         [socketIO disconnectForced];
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    //[socketIO disconnectForced];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    friends = [[NSMutableArray alloc]init];
    friendsID = [[NSMutableArray alloc]init];
    socketIO = [[SocketIO alloc] initWithDelegate:self];
    [socketIO connectToHost:@"vast-woodland-7556.herokuapp.com" onPort:0];
    //self.tableView.delegate = self;
     NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(friendList) userInfo:nil repeats:YES];
    
    [self checkPeople];
    
	// Do any additional setup after loading the view.
}
-(void)friendList
{
    [self checkPeople];
}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    return [UIImage imageWithCGImage:masked];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [self permissionsFB];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)checkPeople
{
    FBRequest *friendsRequest =  [FBRequest  requestWithGraphPath:@"me/friends"
                                                parameters:@{@"fields":@"name,installed,first_name"}
                                                HTTPMethod:@"GET"];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
       NSArray *friendObj = [result objectForKey:@"data"];
        friends = [[NSMutableArray alloc]init];
        friendsID = [[NSMutableArray alloc]init];
        NSLog(@"Found: %i friends", friendObj.count);
        for (NSDictionary<FBGraphUser>* friend in friendObj) {
            if ([friend objectForKey:@"installed"] ){
                NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
                [friends addObject:friend.name];
                [friendsID addObject:friend.id];
            }
            else{
                [tableView reloadData];
                }
            
        }
        
    }];
    
    [tableView reloadData];
    
}

NSString *hostID;

-(void)permissionsFB
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
            NSString *name = userData[@"name"];
            NSString *loca = userData[@"location"][@"name"];
            //[self checkPeople];
            self.userCity.text = loca;
            self.userName.text = name;
            [current setObject:name forKey:@"name"];
            [current setObject:loca forKey:@"location"];
            NSMutableData *imageData = [[NSMutableData alloc] init]; // the data will be loaded in here
            // URL should point to https://graph.facebook.com/{facebookId}/picture?type=large&return_ssl_resources=1
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:7];
            userProfile[@"pictureURL"] = [pictureURL absoluteString];
            [[PFUser currentUser] setObject:userProfile forKey:@"profilePic"];
            UIImage *profPic = [UIImage imageWithData:[NSData dataWithContentsOfURL:pictureURL]];
            [self maskImage:profPic withMask:[UIImage imageNamed:@"profile.png"]];
            [self.profilePicture setImage:profPic];
            // [current setObject:friend forKey:@"friendsOnline"];
            NSLog(@"About to save");
            //NSLog(@"About to save");
            [current saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(!error){
                    NSLog(@"No error"); }
                else {
                    }
            }];
            // Now add the data to the UI elements
            // ...
        }
    }];
    [tableView reloadData];
}



- (void)tableView:(UITableView *)tripsTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //[self checkPeople];
 
   
    return friends.count;
   

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cell";
    static NSString *CellIdentifier2 = @"cellOff";
    FriendCell *cell = [[FriendCell alloc]init];
    
    if (friends.count == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2 forIndexPath:indexPath];
        cell.userName.text = @"No Friends Available";
        return cell;
    
    } else {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.userName.text = [friends objectAtIndex:indexPath.row];
        NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [friendsID objectAtIndex:indexPath.row]]];
        UIImage *profPic = [UIImage imageWithData:[NSData dataWithContentsOfURL:pictureURL]];
        [cell.userPP setImage:profPic];
       // cell.userStatus.text = @"Onlinez";
       /* for(int x = 0; x<myStatus.count; x++)
        {
          
           
            for(int y = 0; y<myStatus.count; y++)
            {
                  NSString *stat = [[myStatus objectAtIndex:x] objectAtIndex:y];
                NSString *stat2 = [friendsID objectAtIndex:y];
                 NSLog(@"STA: %@",stat);
                NSLog(@"%@ and %@", stat, stat2);
                if ([stat2 isEqualToString:stat])
                {
                    NSLog(@"in");
                    if ([[[myStatus objectAtIndex:x] objectAtIndex:x]integerValue] == 0)
                    {
                        
                        cell.userStatus.text = @"Onlinez";
                    }
                    
                }else
                {
                    cell.userStatus.text = @"Offline";
                }
            }
        }*/
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userStatus.text = @"Offline";
        cell.userStatus.textColor = [UIColor redColor];
        
        for (int i = 0; i < myStatus.count; i++) {
            if ([[[myStatus objectAtIndex:i] objectAtIndex:0] isEqualToString:[friendsID objectAtIndex: indexPath.row]]) {
                if ([[[myStatus objectAtIndex:i] objectAtIndex:1]integerValue] == 0) {
                    cell.userStatus.text = @"Online";
                    cell.userStatus.textColor = [UIColor blueColor];
                } else if ([[[myStatus objectAtIndex:i] objectAtIndex:1]integerValue] == 1){
                    cell.userStatus.text = @"Busy";
                    cell.userStatus.textColor = [UIColor orangeColor];
                }
                break;
            }
        
        }
      
        return cell;
        }
   
}

@end
