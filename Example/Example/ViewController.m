//
//  ViewController.m
//  Example
//
//  Created by nickcheng on 13-3-27.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "ViewController.h"
#import "NCWeiboClient.h"
#import "NCWeiboClient+Status.h"
#import "NCWeiboAuthentication.h"
#import "NCWeiboClient+User.h"
#import "NCWeiboErrorResponse.h"
#import "NCWeiboUser.h"
#import "NCWeiboClient+Friendship.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *content;

@end

@implementation ViewController

#pragma mark -
#pragma mark Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //
    [[NCWeiboClient sharedClient] configWithAppKey:@"260591714"];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [NCWeiboClient sharedClient].accessTokenExpiredHandler = ^(APIHandlerBlock apiHandler){
        [[NCWeiboClient sharedClient] logOut];
        [[NCWeiboClient sharedClient] authenticateWithCompletion:^(BOOL success, NCWeiboAuthentication *authentication, NSError *error) {
            if (apiHandler)
                apiHandler();
        } andCancellation:nil];
    };
    [NCWeiboClient sharedClient].authSucceedHandler = ^(){
        NSLog(@"Auth Succeed!");
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Events

- (IBAction)getFollowingTapped:(id)sender {
    [[NCWeiboClient sharedClient] authenticateWithCompletion:^(BOOL success, NCWeiboAuthentication *authentication, NSError *error) {
        NCWeiboUser *user = authentication.user;
        [[NCWeiboClient sharedClient]
            fetchFollowingForUser:user
            completion:^(id responseObject, NSError *error) {
                NSLog(@"result count: %lu", (unsigned long)[(NSArray *)responseObject count]);
            }];
    } andCancellation:nil];
}

- (IBAction)getUserInfoTapped:(id)sender {
    [[NCWeiboClient sharedClient] fetchCurrentUserWithCompletion:^(id responseObject, NSError *error) {
        //
        NCWeiboUser *user = responseObject;
        user.extInfo = @"hello";
        NSLog(@"responseObject: %@", user);
        
        if (error)
            NSLog(@"%@", error);
    }];
}

- (IBAction)clearTapped:(id)sender {
    [[NCWeiboClient sharedClient] logOut];
}

- (IBAction)followTapped:(id)sender {
    [[NCWeiboClient sharedClient] followUserWithID:@"2566997827" completion:^(id responseObject, NSError *error) {
        //
        if (error) {
            NSLog(@"Follow failed. Error:%@", error);
            NSLog(@"User: %@", [NCWeiboClient sharedClient].authentication.user);
        } else {
            NSLog(@"Follow succeed. User: %@", [NCWeiboClient sharedClient].authentication.user);
        }
    }];
}

- (IBAction)sendImageTapped:(id)sender {
    //
    NSString *c = self.content.text;
    [[NCWeiboClient sharedClient]
        composeStatusWithText:c
        andImage:[UIImage imageNamed:@"avator"]
        completion:^(id responseObject, NSError *error) {
            //
            if (error)
                NSLog(@"Post status failed. Error:%@", error);
            else
                NSLog(@"Post succeed.");
        }];
}

- (IBAction)sendTapped:(id)sender {
    //
    NSString *c = self.content.text;
    [[NCWeiboClient sharedClient] createStatusWithText:c
                                              andImage:nil
                                            completion:^(id responseObject, NSError *error) {
                                                //
                                                if (error)
                                                    NSLog(@"Post status failed. Error:%@", error);
                                                else
                                                    NSLog(@"Post succeed.");
                                            }];
}

@end
