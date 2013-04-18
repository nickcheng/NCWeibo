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

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *content;

@end

@implementation ViewController {
  BOOL _authViewHasShown;
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
    }
    else
      NSLog(@"Follow succeed.");
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
                                    andCallbackScheme:@"nextday://"
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
  [[NCWeiboClient sharedClient] setAuthenticationInfo:@"3402471288" andAppSecret:@"23eb634a581fe1c8d699d93c7718ca26" andCallbackScheme:@"nextday://" andViewController:self];
}

-(void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  //
//  if (!_authViewHasShown) {
//    _authViewHasShown = YES;
//    [self doAuth];
//  }
  
  [NCWeiboClient sharedClient].accessTokenExpiredHandler = ^(){
    [[NCWeiboClient sharedClient] logOut];
    [self doAuth];
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
