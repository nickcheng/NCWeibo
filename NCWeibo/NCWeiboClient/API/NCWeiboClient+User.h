//
//  NCWeiboClient+User.h
//  NCWeibo
//
//  Created by nickcheng on 13-3-28.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "NCWeiboClient+HandlerBlocks.h"

@class NCWeiboUser;

@interface NCWeiboClient (User)

- (void)fetchCurrentUserWithCompletion:(NCWeiboClientCompletionBlock)completionHandler;
- (void)fetchUserWithID:(NSString *)userID completion:(NCWeiboClientCompletionBlock)completionHandler;
//- (void)fetchUsersWithIDs:(NSArray *)userIDs completion:(NCWeiboClientCompletionBlock)completionHandler;

- (void)followUser:(NCWeiboUser *)user completion:(NCWeiboClientCompletionBlock)completionHandler;
- (void)followUserWithID:(NSString *)userID completion:(NCWeiboClientCompletionBlock)completionHandler;

@end
