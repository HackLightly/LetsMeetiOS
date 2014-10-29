//
//  ChooseViewController.m
//  LMeet
//
//  Created by Hicham Abou Jaoude on 1/18/2014.
//  Copyright (c) 2014 Hicham Abou Jaoude. All rights reserved.
//

#import "ChooseViewController.h"
#import "FriendCell.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "HostViewViewController.h"
#import "SocketIO.h"

@interface ChooseViewController ()
@property (nonatomic, retain) NSMutableArray *selArray;
@end

@implementation ChooseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)friendList
{
    
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
                //[friendsPP addObject:friend.data];
            }
            else{
                [tableView reloadData];
            }
            
        }
        
    }];
    
    [tableView reloadData];
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toHost"]) {
        [[segue destinationViewController] setChatFriend:chatFriends];
        [[segue destinationViewController] setChatFriendID:chatFriendsID];
        [[segue destinationViewController] setCreate:@"yes"];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    chatFriendsID = [[NSMutableArray alloc]init];
    chatFriends = [[NSMutableArray alloc]init];
    [self checkPeople];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}
int selected = 9;
-(void)viewWillDisappear:(BOOL)animated
{
    [socketIO disconnectForced];
    
}

- (void)tableView:(UITableView *)tripsTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *thisCell = [tableView cellForRowAtIndexPath:indexPath];
    if (thisCell.accessoryType == UITableViewCellAccessoryNone)
    {
     //   NSLog(@"Check Mrk %i, %@", friends.count, [friends objectAtIndex:indexPath.row]);
        [chatFriends addObject:[friends objectAtIndex:indexPath.row]];
        [chatFriendsID addObject:[friendsID objectAtIndex:indexPath.row]];
        NSLog(@"added: %@",[friendsID objectAtIndex:indexPath.row]);
      //  [chatFriendsPP addObject:[friendsPP objectAtIndex:indexPath.row]];
        thisCell.accessoryType = UITableViewCellAccessoryCheckmark;
      //NSLog(@"Check Mrk2 %i, %@", chatFriends.count, [chatFriends objectAtIndex:indexPath.row]);
    }
    else
    {
        thisCell.accessoryType = UITableViewCellAccessoryNone;
        [chatFriends removeObject:[friends objectAtIndex:indexPath.row]];
        [chatFriendsID removeObject:[friendsID objectAtIndex:indexPath.row]];
        NSLog(@"removed: %@",[friendsID objectAtIndex:indexPath.row]);
       // [chatFriendsPP removeObject:[friendsPP objectAtIndex:indexPath.row]];
        
    }
    
    //[tableView reloadData];
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
        
        for (int i = 0; i < self.myStatus.count; i++) {
            if ([[[self.myStatus objectAtIndex:i] objectAtIndex:0] isEqualToString:[friendsID objectAtIndex: indexPath.row]]) {
                if ([[[self.myStatus objectAtIndex:i] objectAtIndex:1]integerValue] == 0) {
                    cell.userStatus.text = @"Online";
                    cell.userStatus.textColor = [UIColor blueColor];
                } else if ([[[self.myStatus objectAtIndex:i] objectAtIndex:1]integerValue] == 1){
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
