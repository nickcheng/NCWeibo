//
//  NCWeiboClient.h
//  NCWeibo
//
//  Created by nickcheng on 13-3-28.
//  Copyright (c) 2013年 NC. All rights reserved.
//

@class NCWeiboAuthentication;

typedef void (^NCWeiboAuthCancellationBlock)(NCWeiboAuthentication *authentication);
typedef void (^NCWeiboAuthCompletionBlock)(BOOL success, NCWeiboAuthentication *authentication, NSError *error);
typedef void (^NCWeiboAccessTokenExpiredBlock)(void (^OriginalAPICallBlock)());
typedef void (^NCWeiboEmptyBlock)();

@interface NCWeiboClient : NSObject

@property (nonatomic, readonly) NSString *appKey;

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NCWeiboAuthentication *authentication;
@property (nonatomic, copy) NCWeiboAccessTokenExpiredBlock accessTokenExpiredHandler; // Actually "doAuthBeforeCallAPI" can make sure access-token work before call API. But in case Weibo changed policy, this block can be a extra guarantee.
@property (nonatomic, copy) void (^originalAPICallBlock)(); // For accessTokenExpiredHandler only.
@property (nonatomic, copy) NCWeiboEmptyBlock authSucceedHandler;

+ (instancetype)sharedClient;

- (void)configWithAppKey:(NSString *)appKey;

- (void)authenticateWithCompletion:(NCWeiboAuthCompletionBlock)completion andCancellation:(NCWeiboAuthCancellationBlock)cancellation;
- (BOOL)tryToAuthWithSavedInfoAndCompletion:(NCWeiboAuthCompletionBlock)completion;
- (BOOL)isAuthenticated;
- (void)logOut;

- (BOOL)handleOpenURL:(NSURL *)url;

@end
