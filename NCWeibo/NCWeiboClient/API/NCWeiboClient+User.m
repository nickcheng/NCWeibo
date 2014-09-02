//
//  NCWeiboClient+User.m
//  NCWeibo
//
//  Created by nickcheng on 13-3-28.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "NCWeiboClient+User.h"
#import "NCWeiboAuthentication.h"
#import "NCWeiboUser.h"

@implementation NCWeiboClient (User)

- (void)fetchCurrentUserWithCompletion:(NCWeiboClientCompletionBlock)completionHandler {
  [self doAuthBeforeCallAPI:^{
    [self fetchUserWithID:self.authentication.userID completion:completionHandler];
  } andAuthErrorProcess:completionHandler];
}

- (void)fetchUserWithID:(NSString *)userID completion:(NCWeiboClientCompletionBlock)completionHandler {
  [self doAuthBeforeCallAPI:^{
    NSDictionary *params = @{
                             @"uid": userID
                             };
    [self GET:@"users/show.json"
       parameters:params
          success:^(NSURLSessionDataTask *task, id responseObject) {
             // make user and replace responseObject
            NCWeiboUser *user = [[NCWeiboUser alloc] initWithJSONDict:responseObject];
            [self processSuccessHandlerWithRequestOperation:task andResponseObject:user andHandler:completionHandler];
           }
           failure:[self failureHandlerForClientHandler:completionHandler]];
  } andAuthErrorProcess:completionHandler];
}

- (void)fetchUserWithName:(NSString *)screenName completion:(NCWeiboClientCompletionBlock)completionHandler {
  [self doAuthBeforeCallAPI:^{
    NSDictionary *params = @{
                             @"screen_name": screenName
                             };
    [self GET:@"users/show.json"
   parameters:params
      success:^(NSURLSessionDataTask *task, id responseObject) {
        // make user and replace responseObject
        NCWeiboUser *user = [[NCWeiboUser alloc] initWithJSONDict:responseObject];
        [self processSuccessHandlerWithRequestOperation:task andResponseObject:user andHandler:completionHandler];
      }
      failure:[self failureHandlerForClientHandler:completionHandler]];
  } andAuthErrorProcess:completionHandler];
}

//- (void)fetchUsersWithIDs:(NSArray *)userIDs completion:(NCWeiboClientCompletionBlock)completionHandler {
//  
//}

- (void)followUser:(NCWeiboUser *)user completion:(NCWeiboClientCompletionBlock)completionHandler {
  return [self followUserWithID:user.userID completion:completionHandler];
}

- (void)followUserWithID:(NSString *)userID completion:(NCWeiboClientCompletionBlock)completionHandler {
  //
  [self doAuthBeforeCallAPI:^{
    NSDictionary *params = @{
                             @"uid": userID
                             };
    [self POST:@"friendships/create.json"
        parameters:params
           success:[self successHandlerForClientHandler:completionHandler]
           failure:[self failureHandlerForClientHandler:completionHandler]];
  } andAuthErrorProcess:completionHandler];
}

@end
