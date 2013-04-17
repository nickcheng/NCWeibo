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

@interface NCWeiboClient : AFHTTPClient

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NCWeiboAuthentication *authentication;
@property (nonatomic, strong) UIViewController *authViewController;
@property (nonatomic, copy) void (^accessTokenExpiredHandler)();

+ (instancetype)sharedClient;

- (void)setAuthenticationInfo:(NSString *)appKey andAppSecret:(NSString *)appSecret andCallbackScheme:(NSString *)ssoCallbackScheme andViewController:(UIViewController *)viewController;
- (void)authenticateWithCompletion:(NCWeiboAuthCompletionBlock)completion andCancellation:(NCWeiboAuthCancellationBlock)cancellation;
- (void)authenticateForAppKey:(NSString *)appKey andAppSecret:(NSString *)appSecret andCallbackScheme:(NSString *)ssoCallbackScheme andViewController:(UIViewController *)viewController andCompletion:(NCWeiboAuthCompletionBlock)completion andCancellation:(NCWeiboAuthCancellationBlock)cancellation;

- (BOOL)isAuthenticated;
- (void)logOut;

@end

extern BOOL SinaWeiboIsDeviceIPad();
