//
//  NCWeiboClient.m
//  NCWeibo
//
//  Created by nickcheng on 13-3-28.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "NCWeiboClient.h"
#import "NCWeiboClientConfig.h"
#import "NCWeiboWebAuthViewController.h"
#import "NCWeiboAuthentication.h"
#import "SSKeychain.h"
#import "NCWeiboClient+User.h"

@implementation NCWeiboClient {
  BOOL _ssoLoggingIn;
  NSString *_accessToken;
  NCWeiboAuthentication *_authentication;
  UIViewController *_authViewController;
  NCWeiboAuthCancellationBlock _authCancellationBlock;
  NCWeiboAuthCompletionBlock _authCompletionBlock;
  AFHTTPClient *_authHTTPClient;
}

@synthesize authentication = _authentication;
@synthesize accessToken = _accessToken;
@synthesize authViewController = _authViewController;

+ (instancetype)sharedClient {
  static NCWeiboClient *sharedNCWeiboClient = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedNCWeiboClient = [[NCWeiboClient alloc] init];
  });
  return sharedNCWeiboClient;
}

+ (NSURL *)APIBaseURL {
	return [NSURL URLWithString:NCWEIBO_APIBASEURL];
}

- (id)init {
  if ((self = [super initWithBaseURL:[[self class] APIBaseURL]])) {
		self.parameterEncoding = AFFormURLParameterEncoding;
//		self.pagination = [[NCWeiboPaginationSettings alloc] init];
		[self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setDefaultHeader:@"User-Agent" value:NCWEIBO_USERAGENT];
//		[self registerHTTPOperationClass:[NCWeiboJSONRequestOperation class]];
		[self addObserver:self forKeyPath:@"accessToken" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"authentication.userID" options:NSKeyValueObservingOptionNew context:nil];
	}
  return self;
}

#pragma mark -
#pragma mark Public Methods

- (void)setAuthenticationInfo:(NSString *)appKey andAppSecret:(NSString *)appSecret andCallbackScheme:(NSString *)ssoCallbackScheme andViewController:(UIViewController *)viewController {
  self.authentication = [[NCWeiboAuthentication alloc] initWithAppKey:appKey andAppSecret:appSecret andCallbackScheme:ssoCallbackScheme];
  self.authViewController = viewController;
}

- (void)authenticateWithCompletion:(NCWeiboAuthCompletionBlock)completion andCancellation:(NCWeiboAuthCancellationBlock)cancellation {
  _authCancellationBlock = cancellation;
  _authCompletionBlock = completion;
  
  // Check saved auth data
  if ([self savedAuthDataIsWorking]) {
    NSLog(@"Got saved auth data");
    if (completion)
      completion(YES, self.authentication, nil);
    return;
  }
  
  // SSO Login
  _ssoLoggingIn = NO;
  UIDevice *device = [UIDevice currentDevice];
  if ([device respondsToSelector:@selector(isMultitaskingSupported)] && [device isMultitaskingSupported]) {
    NSDictionary *params = @{
                             @"client_id": self.authentication.appKey,
                             @"redirect_uri": self.authentication.redirectURI,
                             @"callback_uri": self.authentication.ssoCallbackScheme,
                             };
    // Try iPad first
    NSString *appAuthBaseURL = NCWEIBO_APPAUTHURL_IPAD;
    if (SinaWeiboIsDeviceIPad()) {
      NSString *appAuthURL = [self serializeURL:appAuthBaseURL params:params httpMethod:@"GET"];
      _ssoLoggingIn = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appAuthURL]];
    }
    // Try iPhone
    if (!_ssoLoggingIn) {
      appAuthBaseURL = NCWEIBO_APPAUTHURL_IPHONE;
      NSString *appAuthURL = [self serializeURL:appAuthBaseURL params:params httpMethod:@"GET"];
      _ssoLoggingIn = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appAuthURL]];
    }
  }
  
  // Web oAuth
  if (!_ssoLoggingIn) {
    NCWeiboWebAuthViewController *webAuthVC = [[NCWeiboWebAuthViewController alloc]
                                               initWithAuthentication:_authentication
                                               andCancellation:cancellation
                                               andCompletion:^(BOOL success, NCWeiboAuthentication *authentication, NSError *error) {
                                                 // Get AccessToken
                                                 if ([authentication.authorizationCode isEqualToString:@"21330"]) {
                                                   NSError *error = [NSError errorWithDomain:NCWEIBO_ERRORDOMAIN_OAUTH2 code:21330 userInfo:@{NSLocalizedDescriptionKey:@"NCWeibo.WebAuth.AccessDenied"}];
                                                   if (completion)
                                                     completion(NO, authentication, error);
                                                 } else {
                                                   //
                                                   AFHTTPClient *authHTTPClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:authentication.accessTokenBaseURL]];
                                                   authHTTPClient.parameterEncoding = AFFormURLParameterEncoding;
                                                   [authHTTPClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
                                                   NSDictionary *params = @{
                                                                            @"client_id" : authentication.appKey,
                                                                            @"client_secret": authentication.appSecret,
                                                                            @"redirect_uri": authentication.redirectURI,
                                                                            @"code": authentication.authorizationCode,
                                                                            @"grant_type": @"authorization_code"
                                                                            };
                                                   [authHTTPClient postPath:@"access_token" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                     //
                                                     NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                                                     if (responseDictionary[@"access_token"]) {
                                                       NSString *accessToken = responseDictionary[@"access_token"];
                                                       NSString *userId = responseDictionary[@"uid"];
                                                       int expiresIn = [responseDictionary[@"expires_in"] intValue]; NSLog(@"ExpiresIn: %d", expiresIn);
                                                       if (accessToken.length > 0 && userId.length > 0) {
                                                         self.authentication.accessToken = accessToken;
                                                         self.authentication.expirationDate = [NSDate dateWithTimeIntervalSinceNow:expiresIn];
                                                         self.authentication.userID = userId;
                                                         self.accessToken = accessToken;
                                                         if (completion)
                                                           completion(YES, self.authentication, nil);
                                                         return;
                                                       }
                                                     }
                                                     NSError *error = [NSError errorWithDomain:NCWEIBO_ERRORDOMAIN_OAUTH2 code:-1 userInfo:@{NSLocalizedDescriptionKey: @"NCWeibo.WebAuth.AccessTokenNotFound", NSLocalizedFailureReasonErrorKey: responseDictionary}];
                                                     if (completion)
                                                       completion(NO, authentication, error);
                                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                     if (completion)
                                                       completion(NO, authentication, error);
                                                   }];
                                                 }
                                               }];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:webAuthVC];
    [self.authViewController presentViewController:navController animated:YES completion:NULL];
  }
}

- (void)authenticateForAppKey:(NSString *)appKey andAppSecret:(NSString *)appSecret andCallbackScheme:(NSString *)ssoCallbackScheme andViewController:(UIViewController *)viewController andCompletion:(NCWeiboAuthCompletionBlock)completion andCancellation:(NCWeiboAuthCancellationBlock)cancellation {
  //
  [self setAuthenticationInfo:appKey andAppSecret:appSecret andCallbackScheme:ssoCallbackScheme andViewController:viewController];
  [self authenticateWithCompletion:completion andCancellation:cancellation];
}

- (BOOL)isAuthenticated {
	return (
          self.accessToken != nil
          && self.authentication
          && self.authentication.expirationDate
          && ([self.authentication.expirationDate compare:[NSDate date]] == NSOrderedDescending)
          );
}

- (void)logOut {
	self.accessToken = nil;
}

#pragma mark -
#pragma mark Private Methods

- (BOOL)savedAuthDataIsWorking {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSDictionary *authData = [defaults objectForKey:@"NCWeiboAuthData"];
  if (authData[@"UserID"] && authData[@"ExpirationDate"] && authData[@"AppKey"]) {
    NSString *appkey = authData[@"AppKey"];
    if (![appkey isEqualToString:self.authentication.appKey]) {
      [self removeAuthData];
      return NO;
    }
    NSString *userID = authData[@"UserID"];
    NSDate *expirationDate = authData[@"ExpirationDate"]; NSLog(@"ExpirationDate: %@", expirationDate);
    NSDate *now = [NSDate date];
    if ([expirationDate compare:now] == NSOrderedAscending)
      return NO;
    
    // access token is working
    SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
    query.service = NCWEIBO_KEYCHAINSERVICE;
    query.account = NCWEIBO_KEYCHAINACCOUNT;
    [query fetch:nil];
    NSString *token = query.password;
    self.authentication.accessToken = token;
    self.authentication.expirationDate = expirationDate;
    self.authentication.userID = userID;
    self.accessToken = token;
    return YES;
  }
  return NO;
}

- (void)removeAuthData {
  // Delete authentication from NSUserDefault
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NCWeiboAuthData"];
  [[NSUserDefaults standardUserDefaults] synchronize];

  // Delete from keychain
  SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
  query.service = NCWEIBO_KEYCHAINSERVICE;
  query.account = NCWEIBO_KEYCHAINACCOUNT;
  [query delete:nil];
  
  NSLog(@"Auth data deleted.");
}

- (void)storeAuthData {
  // Save authentication to NSUserDefault
  NSDictionary *authData = @{
                             @"UserID": self.authentication.userID,
                             @"ExpirationDate": self.authentication.expirationDate,
                             @"AppKey": self.authentication.appKey
                             };
  [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"NCWeiboAuthData"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  // Save access token to Keychain
  SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
  query.service = NCWEIBO_KEYCHAINSERVICE;
  query.account = NCWEIBO_KEYCHAINACCOUNT;
  query.password = self.accessToken;
  [query save:nil];
  
  NSLog(@"Auth data saved.");
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	// AccessToken
  if ([keyPath isEqualToString:@"accessToken"]) {
		if (self.accessToken) {
			[self setDefaultHeader:@"Authorization" value:[@"OAuth2 " stringByAppendingString:self.accessToken]];
      [self storeAuthData];
      self.authentication.userID = self.authentication.userID; // When get token, trigger "authentication.userID" again to fetch user.
		} else {
			[self setDefaultHeader:@"Authorization" value:nil];
      [self removeAuthData];
		}
	}
  
  // Authentication.userID
  if ([keyPath isEqualToString:@"authentication.userID"]) {
    if (self.isAuthenticated && self.authentication.userID && !self.authentication.user) {
      [self fetchCurrentUserWithCompletion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        self.authentication.user = responseObject;
      }];
    }
  }
  
}

- (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(NSString *)httpMethod
{
  NSURL* parsedURL = [NSURL URLWithString:baseURL];
  NSString* queryPrefix = parsedURL.query ? @"&" : @"?";
  
  NSMutableArray* pairs = [NSMutableArray array];
  for (NSString* key in [params keyEnumerator])
  {
    if (([[params objectForKey:key] isKindOfClass:[UIImage class]])
        ||([[params objectForKey:key] isKindOfClass:[NSData class]]))
    {
      if ([httpMethod isEqualToString:@"GET"])
      {
        NSLog(@"can not use GET to upload a file");
      }
      continue;
    }

    NSString* escaped_value = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                  NULL, /* allocator */
                                                                                  (__bridge CFStringRef)[params objectForKey:key],
                                                                                  NULL, /* charactersToLeaveUnescaped */
                                                                                  CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                  kCFStringEncodingUTF8);
    
    [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
  }
  NSString* query = [pairs componentsJoinedByString:@"&"];
  
  return [NSString stringWithFormat:@"%@%@%@", baseURL, queryPrefix, query];
}

BOOL SinaWeiboIsDeviceIPad()
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
  {
    return YES;
  }
#endif
  return NO;
}

@end
