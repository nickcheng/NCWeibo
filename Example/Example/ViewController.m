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

@implementation ViewController {
  BOOL _authViewHasShown;
}

- (IBAction)getFollowingTapped:(id)sender {
  [[NCWeiboClient sharedClient] authenticateWithCompletion:^(BOOL success, NCWeiboAuthentication *authentication, NSError *error) {
    NCWeiboUser *user = authentication.user;
    [[NCWeiboClient sharedClient] fetchFollowingForUser:user
                                             completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
                                               NSLog(@"result count: %d", [(NSArray *)responseObject count]);
                                             }];
  } andCancellation:nil];
}

- (IBAction)getUserInfoTapped:(id)sender {
  [[NCWeiboClient sharedClient] fetchCurrentUserWithCompletion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
    //
    NCWeiboUser *user = responseObject;
    NSLog(@"responseObject: %@", user);
  }];
}

- (IBAction)clearTapped:(id)sender {
  [[NCWeiboClient sharedClient] logOut];
}

- (IBAction)followTapped:(id)sender {
  [[NCWeiboClient sharedClient] followUserWithID:@"2566997827" completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
    //
    if (error) {
      NSLog(@"Follow failed. Error:%@", error);
      NSLog(@"User: %@", [NCWeiboClient sharedClient].authentication.user);
    }
    else
      NSLog(@"Follow succeed. User: %@", [NCWeiboClient sharedClient].authentication.user);
  }];
}

- (IBAction)sendImageTapped:(id)sender {
  //
  NSString *c = self.content.text;
  [[NCWeiboClient sharedClient] createStatusWithText:c andImage:[UIImage imageNamed:@"avator"]
                                          completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
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
  [[NCWeiboClient sharedClient] createStatusWithText:c andImage:nil
                                        completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
                                          //
                                          if (error)
                                            NSLog(@"Post status failed. Error:%@", error);
                                          else
                                            NSLog(@"Post succeed.");
                                        }];
}

- (void)doAuth {
  [[NCWeiboClient sharedClient] authenticateForAppKey:@"3402471288"
                                         andAppSecret:@"23eb634a581fe1c8d699d93c7718ca26"
                                    andCallbackScheme:@"nextday://com.nxmix.nextday.login"
                                    andViewController:self
                                        andCompletion:^(BOOL success, NCWeiboAuthentication *authentication, NSError *error) {
                                          //
                                          if (success)
                                            NSLog(@"Auth successed! Token: %@", authentication.accessToken);
                                          else
                                            NSLog(@"Auth failed! Error: %@", error);
                                        }
                                      andCancellation:^(NCWeiboAuthentication *authentication) {
                                        //
                                        NSLog(@"Auth cancelled!");
                                      }];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  //
  _authViewHasShown = NO;
  
  //
  [[NCWeiboClient sharedClient] setAuthenticationInfo:@"3402471288" andAppSecret:@"23eb634a581fe1c8d699d93c7718ca26" andCallbackScheme:@"nextday://com.nxmix.nextday.login" andViewController:self];
}

-(void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  //
//  if (!_authViewHasShown) {
//    _authViewHasShown = YES;
//    [self doAuth];
//  }
  
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

- (void)viewDidUnload {
  [self setContent:nil];
  [super viewDidUnload];
}
@end
