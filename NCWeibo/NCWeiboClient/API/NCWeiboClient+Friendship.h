//
//  NCWeiboClient+Friendship.h
//  NCWeibo
//
//  Created by nickcheng on 13-3-28.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "NCWeiboClient+HandlerBlocks.h"

@class NCWeiboUser;

@interface NCWeiboClient (Friendship)

- (void)fetchFollowingForUser:(NCWeiboUser *)user completion:(NCWeiboClientCompletionBlock)completionHandler;
- (void)fetchFollowingForUserID:(NSString *)userID completion:(NCWeiboClientCompletionBlock)completionHandler;

@end
