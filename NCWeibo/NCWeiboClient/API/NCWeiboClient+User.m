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
  }];
}

- (void)fetchUserWithID:(NSString *)userID completion:(NCWeiboClientCompletionBlock)completionHandler {
  [self doAuthBeforeCallAPI:^{
    NSDictionary *params = @{
                             @"uid": userID
                             };
    [self getPath:@"users/show.json"
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
             // make user and replace responseObject
            NCWeiboUser *user = [[NCWeiboUser alloc] initWithJSONString:operation.responseString];
            [self processSuccessHandlerWithRequestOperation:operation andResponseObject:user andHandler:completionHandler];
           }
           failure:[self failureHandlerForClientHandler:completionHandler]];
  }];
}

//- (void)fetchUsersWithIDs:(NSArray *)userIDs completion:(NCWeiboClientCompletionBlock)completionHandler {
//  
//}

- (void)followUser:(NCWeiboUser *)user completion:(NCWeiboClientCompletionBlock)completionHandler {
  return [self followUserWithID:user.userId completion:completionHandler];
}

- (void)followUserWithID:(NSString *)userID completion:(NCWeiboClientCompletionBlock)completionHandler {
  //
  [self doAuthBeforeCallAPI:^() {
    NSDictionary *params = @{
                             @"uid": userID
                             };
    [self postPath:@"friendships/create.json"
        parameters:params
           success:[self successHandlerForClientHandler:completionHandler]
           failure:[self failureHandlerForClientHandler:completionHandler]];
  }];
}

@end
