//
//  ViewController.m
//  LMeet
//
//  Created by Hicham Abou Jaoude on 1/17/2014.
//  Copyright (c) 2014 Hicham Abou Jaoude. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "SocketIOPacket.h"
@interface ViewController () <FBFriendPickerDelegate>
@property (weak, nonatomic) IBOutlet FBFriendPickerViewController *friendPickerController;
@property (weak, nonatomic) IBOutlet FBFriendPickerViewController *friendsController;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)link:(id)sender
{
    [self signUPFB];
}

-(BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker shouldIncludeUser:(id<FBGraphUser>)user{
    NSLog(@"Test");
    BOOL installed = [user objectForKey:@"installed"] != nil;
    return installed;
}

-(void)signUPFB
{
    NSArray *permissions = @[ @"user_about_me", @"user_relationships", @"read_friendlists", @"user_location"];
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
            //...
            NSSet *fields = [NSSet setWithObjects:@"installed", nil];
            self.friendPickerController.fieldsForRequest = fields;
            [self performSegueWithIdentifier:@"toProfile" sender:self];
      
        } else {
            NSLog(@"User logged in through Facebook!");
            NSSet *fields = [NSSet setWithObjects:@"installed", nil];
            self.friendPickerController.fieldsForRequest = fields;
            [self performSegueWithIdentifier:@"toProfile" sender:self];
        }
    }];
}




@end
