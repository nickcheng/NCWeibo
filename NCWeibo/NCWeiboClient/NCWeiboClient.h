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
@property (nonatomic, copy) void (^accessTokenExpiredHandler)();

+ (instancetype)sharedClient;

- (void)authenticateForAppKey:(NSString *)appKey andAppSecret:(NSString *)appSecret andCallbackScheme:(NSString *)ssoCallbackScheme andViewController:(UIViewController *)viewController andCancellation:(NCWeiboAuthCancellationBlock)cancellation andCompletion:(NCWeiboAuthCompletionBlock)completion;

- (BOOL)isAuthenticated;
- (void)logOut;

@end

extern BOOL SinaWeiboIsDeviceIPad();
