//
//  NCWeiboAuthorize.h
//  NCWeibo
//
//  Created by nickcheng on 13-3-31.
//  Copyright (c) 2013年 NC. All rights reserved.
//

@class NCWeiboUser;

@interface NCWeiboAuthentication : NSObject

@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, strong) NSString *appSecret;
@property (nonatomic, strong) NSString *redirectURI;
@property (nonatomic, strong) NSString *ssoCallbackScheme;

@property (nonatomic, strong) NSString *authorizeURL;
@property (nonatomic, strong) NSString *accessTokenBaseURL;

@property (nonatomic, strong) NSString *authorizationCode;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSDate *expirationDate;
@property (nonatomic, strong) NCWeiboUser *user;

- (id)initWithAppKey:(NSString *)appKey andAppSecret:(NSString *)appSecret andCallbackScheme:(NSString *)ssoCallbackScheme;

@end
