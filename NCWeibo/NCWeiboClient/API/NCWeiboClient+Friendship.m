//
//  NCWeiboClient+Friendship.m
//  NCWeibo
//
//  Created by nickcheng on 13-3-28.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "NCWeiboClient+Friendship.h"
#import "NCWeiboUser.h"
#import "NCWeiboClientConfig.h"
#import "NCWeiboClient+User.h"

@implementation NCWeiboClient (Friendship)

- (void)fetchFollowingForUser:(NCWeiboUser *)user completion:(NCWeiboClientCompletionBlock)completionHandler {
  if (user == nil) {
    [self failureHandlerForClientHandler:completionHandler];
    return;
  }
  
  //
  [self doAuthBeforeCallAPI:^{
    //
    NSInteger followingCount = user.friendsCount;
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    resultDict[@"counter"] = @0;
    resultDict[@"array"] = [[NSMutableArray alloc] init];
    NSInteger cursor = 0;
    
    //
    dispatch_queue_t fetchqueue = dispatch_queue_create("com.nxmix.nextday.fetchfollowing", NULL);
    while (cursor < followingCount) {
      NSDictionary *params = @{
                               @"uid": [NSNumber numberWithDouble:user.userID.doubleValue],
                               @"count": [NSNumber numberWithInt:NCWEIBO_PAGESIZE],
                               @"cursor": [NSNumber numberWithInteger:cursor],
                               };
      dispatch_async(fetchqueue, ^{
        [self getPath:@"friendships/friends.json"
           parameters:params
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                //
                NSError *jsonError;
                NSDictionary *jsonDict = [NSJSONSerialization
                                          JSONObjectWithData:[operation.responseString dataUsingEncoding:NSUTF8StringEncoding]
                                          options:NSJSONReadingMutableContainers error:&jsonError];
                if (jsonError != nil) {
                  NCLogError(@"Generate JSONDict Error: %@", jsonError);
                  [self failureHandlerForClientHandler:completionHandler];
                  return;
                }
                
                //
                for (NSDictionary *dict in jsonDict[@"users"]) {
                  NCWeiboUser *user = [[NCWeiboUser alloc] initWithJSONDict:dict];
                  [resultDict[@"array"] addObject:user];
                }
                resultDict[@"counter"] = [NSNumber numberWithInteger:[resultDict[@"counter"] integerValue] - 1];
                
                //
                if ([resultDict[@"counter"] integerValue] <= 0)
                  [self processSuccessHandlerWithRequestOperation:operation
                                                andResponseObject:resultDict[@"array"]
                                                       andHandler:completionHandler];
              }
              failure:[self failureHandlerForClientHandler:completionHandler]];
      });
      
      //
      resultDict[@"counter"] = [NSNumber numberWithInteger:[resultDict[@"counter"] integerValue] + 1];
      cursor += NCWEIBO_PAGESIZE;
    }
  } andAuthErrorProcess:completionHandler];
}

- (void)fetchFollowingForUserID:(NSString *)userID completion:(NCWeiboClientCompletionBlock)completionHandler {
  [self fetchUserWithID:userID completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
    NCWeiboUser *user = responseObject;
    [self fetchFollowingForUser:user completion:completionHandler];
  }];
}

@end
