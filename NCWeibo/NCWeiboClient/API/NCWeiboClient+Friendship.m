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
#import "WeiboSDK.h"


@implementation NCWeiboClient (Friendship)

- (void)fetchFollowingForUser:(NCWeiboUser *)user completion:(NCWeiboClientCompletionBlock)completionHandler {
    if (user == nil) {
        NSError *error = [NSError
            errorWithDomain:NCWEIBO_ERRORDOMAIN_API
            code:400
            userInfo:@{
                NSLocalizedDescriptionKey:@"Don't have user info."
            }];
        [self processRequestCompletion:nil result:nil error:error handler:completionHandler];
        return;
    }
    
    //
    [self doAuthBeforeCallAPI:^{
        NSOperationQueue *fetchQueue = [[NSOperationQueue alloc] init];
        fetchQueue.maxConcurrentOperationCount =1;
        
        NSMutableArray *resultArray = [[NSMutableArray alloc] init];
        
        NSInteger followingCount = user.friendsCount;
        NSInteger cursor = 0;
        
        while (cursor < followingCount) {
            // Doc: http://open.weibo.com/wiki/2/friendships/friends/en .
            NSDictionary *extraParaDict = @{
                                            @"cursor": @(cursor),
                                            @"count": @(NCWEIBO_PAGESIZE),
                                            };
            
            [WBHttpRequest
                requestForFriendsListOfUser:user.userID
                withAccessToken:self.accessToken
                andOtherProperties:extraParaDict
                queue:fetchQueue
                withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                    if (error) {
                        [self processRequestCompletion:nil result:nil error:error handler:completionHandler];
                        return;
                    }
                    
                    NSDictionary *resultDict = result;
                    for (NSDictionary *dict in resultDict[@"users"]) {
                        NCWeiboUser *user = [[NCWeiboUser alloc] initWithJSONDict:dict];
                        [resultArray addObject:user];
                    }
                    
                    if ([resultDict[@"next_cursor"] integerValue] <= 0) {
                        [self processRequestCompletion:httpRequest result:resultDict error:nil handler:completionHandler];
                    }
                }];
            
            //
            cursor += NCWEIBO_PAGESIZE;
        }
    } andAuthErrorProcess:completionHandler];
}

- (void)fetchFollowingForUserID:(NSString *)userID completion:(NCWeiboClientCompletionBlock)completionHandler {
    [self fetchUserWithID:userID completion:^(id responseObject, NSError *error) {
        NCWeiboUser *user = responseObject;
        [self fetchFollowingForUser:user completion:completionHandler];
    }];
}

@end
