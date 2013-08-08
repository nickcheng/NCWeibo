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
  if ([self tryToAuthWithSavedInfoAndCompletion:completion])
    return;
  
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
                                                     NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                                                     [self logInDidFinishWithAuthInfo:responseDictionary];
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

- (BOOL)handleOpenURL:(NSURL *)url {
  NSString *urlString = [url absoluteString];
  NSLog(@"URL: %@", urlString);

  if ([urlString hasPrefix:self.authentication.ssoCallbackScheme]) {
    if (!_ssoLoggingIn) {
      // sso callback after user have manually opened the app
      // ignore the request
    } else {
      _ssoLoggingIn = NO;
      
      if ([self getParamValueFromUrl:urlString paramName:@"sso_error_user_cancelled"]) {
        if (_authCancellationBlock != nil) {
          _authCancellationBlock(self.authentication);
        }
      } else if ([self getParamValueFromUrl:urlString paramName:@"sso_error_invalid_params"]) {
        if (_authCompletionBlock != nil) {
          NSString *error_description = @"Invalid sso params";
          NSDictionary *userInfo = @{NSLocalizedDescriptionKey: error_description};
          NSError *error = [NSError errorWithDomain:NCWEIBO_ERRORDOMAIN_OAUTH2
                                               code:NCWeiboErrorCodeSSOParamsError
                                           userInfo:userInfo];
          _authCompletionBlock(NO, self.authentication, error);
        }
      } else if ([self getParamValueFromUrl:urlString paramName:@"error_code"]) {
        if (_authCompletionBlock != nil) {
          NSString *error_code = [self getParamValueFromUrl:urlString paramName:@"error_code"];
          NSString *error = [self getParamValueFromUrl:urlString paramName:@"error"];
          NSString *error_uri = [self getParamValueFromUrl:urlString paramName:@"error_uri"];
          NSString *error_description = [self getParamValueFromUrl:urlString paramName:@"error_description"];
          NSDictionary *errorInfo = @{
                                      @"error": error,
                                      @"error_uri": error_uri,
                                      @"error_code": error_code,
                                      @"error_description": error_description
                                      };
          NSDictionary *userInfo = @{
                                     @"error": errorInfo,
                                     NSLocalizedDescriptionKey: error_description
                                     };
          NSError *err = [NSError errorWithDomain:NCWEIBO_ERRORDOMAIN_OAUTH2
                                             code:error_code.intValue
                                         userInfo:userInfo];
          _authCompletionBlock(NO, self.authentication, err);
        }
      } else {
        NSString *access_token = [self getParamValueFromUrl:urlString paramName:@"access_token"];
        NSString *expires_in = [self getParamValueFromUrl:urlString paramName:@"expires_in"];
        NSString *remind_in = [self getParamValueFromUrl:urlString paramName:@"remind_in"];
        NSString *uid = [self getParamValueFromUrl:urlString paramName:@"uid"];
        NSString *refresh_token = [self getParamValueFromUrl:urlString paramName:@"refresh_token"];
        
        NSMutableDictionary *authInfo = [NSMutableDictionary dictionary];
        if (access_token) [authInfo setObject:access_token forKey:@"access_token"];
        if (expires_in) [authInfo setObject:expires_in forKey:@"expires_in"];
        if (remind_in) [authInfo setObject:remind_in forKey:@"remind_in"];
        if (refresh_token) [authInfo setObject:refresh_token forKey:@"refresh_token"];
        if (uid) [authInfo setObject:uid forKey:@"uid"];
        
        [self logInDidFinishWithAuthInfo:authInfo];
      }
    }
  }

  return YES;
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

- (BOOL)tryToAuthWithSavedInfoAndCompletion:(NCWeiboAuthCompletionBlock)completion {
  if ([self savedAuthDataIsWorking]) {
    NCLogInfo(@"Got saved auth data");
    [self fetchCurrentUserWithCompletion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
      self.authentication.user = responseObject;
      
      // Completion
      if (completion)
        completion(YES, self.authentication, nil);
      
      // authSucceedHandler
      if (self.authSucceedHandler != nil)
        self.authSucceedHandler();
    }];
    
    return YES;
  }
  
  return NO;
}

#pragma mark -
#pragma mark Private Methods

- (void)logInDidFinishWithAuthInfo:(NSDictionary *)authInfo {
  if (authInfo[@"access_token"] != nil) {
    NSString *accessToken = authInfo[@"access_token"];
    NSString *userID = authInfo[@"uid"];
    int expiresIn = [authInfo[@"expires_in"] intValue];
    if (accessToken.length > 0 && userID.length > 0) {
      self.authentication.accessToken = accessToken;
      self.authentication.expirationDate = [NSDate dateWithTimeIntervalSinceNow:expiresIn];
      self.authentication.userID = userID;
      self.accessToken = accessToken;
      [self fetchCurrentUserWithCompletion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        self.authentication.user = responseObject;
        
        // Completion
        if (_authCompletionBlock)
          _authCompletionBlock(YES, self.authentication, nil);
        
        // authSucceedHandler
        if (self.authSucceedHandler != nil)
          self.authSucceedHandler();
      }];
      return;
    }
  }
  if (_authCompletionBlock != nil) {
    NSError *error = [NSError errorWithDomain:NCWEIBO_ERRORDOMAIN_OAUTH2 code:-1 userInfo:@{NSLocalizedDescriptionKey: @"NCWeibo.WebAuth.AccessTokenNotFound", NSLocalizedFailureReasonErrorKey: authInfo}];
    _authCompletionBlock(NO, self.authentication, error);
  }
}

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
    NSDate *expirationDate = authData[@"ExpirationDate"]; NCLogInfo(@"ExpirationDate: %@", expirationDate);
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
  
  NCLogInfo(@"Auth data deleted.");
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
  
  NCLogInfo(@"Auth data saved.");
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
}

- (NSString *)getParamValueFromUrl:(NSString*)url paramName:(NSString *)paramName {
  if (![paramName hasSuffix:@"="]) {
    paramName = [NSString stringWithFormat:@"%@=", paramName];
  }
  
  NSString *str = nil;
  NSRange start = [url rangeOfString:paramName];
  if (start.location != NSNotFound) {
    // confirm that the parameter is not a partial name match
    unichar c = '?';
    if (start.location != 0) {
      c = [url characterAtIndex:start.location - 1];
    }
    if (c == '?' || c == '&' || c == '#') {
      NSRange end = [[url substringFromIndex:start.location+start.length] rangeOfString:@"&"];
      NSUInteger offset = start.location+start.length;
      str = end.location == NSNotFound ?
      [url substringFromIndex:offset] :
      [url substringWithRange:NSMakeRange(offset, end.location)];
      str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
  }
  return str;
}

- (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(NSString *)httpMethod {
  NSURL* parsedURL = [NSURL URLWithString:baseURL];
  NSString* queryPrefix = parsedURL.query ? @"&" : @"?";
  
  NSMutableArray* pairs = [NSMutableArray array];
  for (NSString* key in [params keyEnumerator]) {
    if (([[params objectForKey:key] isKindOfClass:[UIImage class]])
        ||([[params objectForKey:key] isKindOfClass:[NSData class]])) {
      if ([httpMethod isEqualToString:@"GET"]) {
        NCLogInfo(@"can not use GET to upload a file");
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

BOOL SinaWeiboIsDeviceIPad() {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    return YES;
  }
#endif
  return NO;
}

@end
