//
//  NCWeiboAuthorize.m
//  NCWeibo
//
//  Created by nickcheng on 13-3-31.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "NCWeiboAuthentication.h"
#import "NCWeiboClientConfig.h"
#import "NCWeiboUser.h"

@implementation NCWeiboAuthentication {
  NSString *_appKey;
  NSString *_appSecret;
  NSString *_redirectURI;
  NSString *_ssoCallbackScheme;
  
  NSString *_authorizeURL;
  NSString *_accessTokenBaseURL;
  
  NSString *_authorizationCode;
  NSString *_accessToken;
  NSString *_userID;
  NSDate *_expirationDate;
  NCWeiboUser *_user;
}

@synthesize appKey = _appKey;
@synthesize appSecret = _appSecret;
@synthesize redirectURI = _redirectURI;
@synthesize ssoCallbackScheme = _ssoCallbackScheme;

@synthesize authorizeURL = _authorizeURL;
@synthesize accessTokenBaseURL = _accessTokenBaseURL;

@synthesize authorizationCode = _authorizationCode;
@synthesize accessToken = _accessToken;
@synthesize userID = _userID;
@synthesize expirationDate = _expirationDate;
@synthesize user = _user;

- (id)initWithAppKey:(NSString *)appKey andAppSecret:(NSString *)appSecret andCallbackScheme:(NSString *)ssoCallbackScheme {
  //
	if((self = [super init]) == nil) return nil;

  //
  _appKey = appKey;
  _appSecret = appSecret;
  _ssoCallbackScheme = ssoCallbackScheme;

  _redirectURI = @"http://";
  _authorizeURL = [NSString stringWithFormat:@"%@?client_id=%@&response_type=code&redirect_uri=%@&display=mobile",
                   NCWEIBO_APPAUTHURL,
                   [_appKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                   [_redirectURI stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  _accessTokenBaseURL = NCWEIBO_ACCESSTOKENBASEURL;

  //
  return self;
}

@end
