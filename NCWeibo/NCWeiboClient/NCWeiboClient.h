//
//  NCWeiboClient.h
//  NCWeibo
//
//  Created by nickcheng on 13-3-28.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "AFNetworking.h"

@class NCWeiboAuthentication;

typedef void (^NCWeiboAuthCancellationBlock)(NCWeiboAuthentication *authentication);
typedef void (^NCWeiboAuthCompletionBlock)(BOOL success, NCWeiboAuthentication *authentication, NSError *error);
typedef void (^NCWeiboAccessTokenExpiredBlock)(void (^OriginalAPICallBlock)());

@interface NCWeiboClient : AFHTTPClient

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NCWeiboAuthentication *authentication;
@property (nonatomic, strong) UIViewController *authViewController;
@property (nonatomic, copy) NCWeiboAccessTokenExpiredBlock accessTokenExpiredHandler; // Actually "doAuthBeforeCallAPI" can make sure access-token work before call API. But in case Weibo changed policy, this block can be a extra guarantee.
@property (nonatomic, copy) void (^originalAPICallBlock)(); // For accessTokenExpiredHandler only.

+ (instancetype)sharedClient;

- (void)setAuthenticationInfo:(NSString *)appKey andAppSecret:(NSString *)appSecret andCallbackScheme:(NSString *)ssoCallbackScheme andViewController:(UIViewController *)viewController;
- (void)authenticateWithCompletion:(NCWeiboAuthCompletionBlock)completion andCancellation:(NCWeiboAuthCancellationBlock)cancellation;
- (void)authenticateForAppKey:(NSString *)appKey andAppSecret:(NSString *)appSecret andCallbackScheme:(NSString *)ssoCallbackScheme andViewController:(UIViewController *)viewController andCompletion:(NCWeiboAuthCompletionBlock)completion andCancellation:(NCWeiboAuthCancellationBlock)cancellation;

- (BOOL)isAuthenticated;
- (void)logOut;

@end

extern BOOL SinaWeiboIsDeviceIPad();
