//
//  NCWeiboClient.m
//  NCWeibo
//
//  Created by nickcheng on 13-3-28.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "NCWeiboClient.h"
#import "NCWeiboClientConfig.h"
#import "NCWeiboAuthentication.h"
#import "SAMKeychain.h"
#import "NCWeiboClient+User.h"
#import "WeiboSDK.h"


NSString * const kNCWeiboRedirectURI = @"http://";
NSString * const kNCWeiboScope = @"all";

@interface NCWeiboClient () <WeiboSDKDelegate>

@property (nonatomic, readwrite) NSString *appKey;

@end

@implementation NCWeiboClient {
    NCWeiboAuthCancellationBlock _authCancellationBlock;
    NCWeiboAuthCompletionBlock _authCompletionBlock;
}

#pragma mark -
#pragma mark Init

+ (instancetype)sharedClient {
    static NCWeiboClient *sharedNCWeiboClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedNCWeiboClient = [[NCWeiboClient alloc] init];
    });
    return sharedNCWeiboClient;
}

- (id)init {
    self = [super init];
    if (self == nil) return nil;
    
    //
    _appKey = @"";
    _authentication = [[NCWeiboAuthentication alloc] init];
    
    return self;
}

#pragma mark -
#pragma mark Public Methods

- (void)configWithAppKey:(NSString *)appKey {
    self.appKey = appKey;
    
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:appKey];
}

- (void)authenticateWithCompletion:(NCWeiboAuthCompletionBlock)completion andCancellation:(NCWeiboAuthCancellationBlock)cancellation {
    _authCancellationBlock = cancellation;
    _authCompletionBlock = completion;
    
    // Check saved auth data
    if ([self tryToAuthWithSavedInfoAndCompletion:completion]) {
        return;
    }
    
    //
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kNCWeiboRedirectURI;
    request.scope = kNCWeiboScope;
//    request.userInfo = nil;
    [WeiboSDK sendRequest:request];
}

- (BOOL)handleOpenURL:(NSURL *)url {
    NSString *urlString = [url absoluteString];
    NCLogInfo(@"URL: %@", urlString);
    
    return [WeiboSDK handleOpenURL:url delegate:self];
}

- (BOOL)isAuthenticated {
    return (
            self.accessToken
            && self.authentication
            && self.authentication.expirationDate
            && ([self.authentication.expirationDate compare:[NSDate date]] == NSOrderedDescending)
            );
}

- (void)logOut {
    [WeiboSDK logOutWithToken:self.accessToken delegate:nil withTag:nil]; // todo: implement delegate
    [self clearAuthData];
    self.accessToken = nil;
}

- (BOOL)tryToAuthWithSavedInfoAndCompletion:(NCWeiboAuthCompletionBlock)completion {
    if ([self savedAuthDataIsWorking]) {
        NCLogInfo(@"Got saved auth data");
        [self fetchCurrentUserWithCompletion:^(id responseObject, NSError *error) {
            // Handle error
            if (error != nil) {
                NCLogError(@"Fetch current user error: %@", error);
                return;
            }
            
            //
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

- (void)processSuccessfulAuthorizeResponse:(WBAuthorizeResponse *)response {
    NSString *accessToken = response.accessToken;
    NSString *userID = response.userID;
    
    if (accessToken && accessToken.length > 0
        && userID && userID.length > 0) {
        self.authentication.accessToken = accessToken;
        self.authentication.expirationDate = response.expirationDate;
        self.authentication.userID = userID;
        self.accessToken = accessToken;
        [self storeAuthData];
        [self fetchCurrentUserWithCompletion:^(id responseObject, NSError *error) {
            self.authentication.user = responseObject;
            
            // Completion
            if (_authCompletionBlock)
                _authCompletionBlock(YES, self.authentication, nil);
            
            // authSucceedHandler
            if (self.authSucceedHandler != nil)
                self.authSucceedHandler();
        }];
    } else if (_authCompletionBlock != nil) {
        NSError *error = [NSError
                          errorWithDomain:NCWEIBO_ERRORDOMAIN_GENERAL
                          code:-1
                          userInfo:@{
                                     NSLocalizedDescriptionKey: @"Didn't find accesstoken in WBAuthorizeResponse"
                                     }];
        _authCompletionBlock(NO, self.authentication, error);
    }
}

#pragma mark -
#pragma mark AuthData

- (BOOL)savedAuthDataIsWorking {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *authData = [defaults objectForKey:@"NCWeiboAuthData"];
    if (authData[@"UserID"] && authData[@"ExpirationDate"] && authData[@"AppKey"]) {
        NSString *appkey = authData[@"AppKey"];
        if (![appkey isEqualToString:self.appKey]) {
            [self clearAuthData];
            return NO;
        }
        NSString *userID = authData[@"UserID"];
        NSDate *expirationDate = authData[@"ExpirationDate"];
        NCLogInfo(@"ExpirationDate: %@", expirationDate);
        NSDate *now = [NSDate date];
        if ([expirationDate compare:now] == NSOrderedAscending)
            return NO;
        
        // access token is working
        SAMKeychainQuery *query = [[SAMKeychainQuery alloc] init];
        query.service = NCWEIBO_KEYCHAINSERVICE;
        query.account = NCWEIBO_KEYCHAINACCOUNT;
        
        NSError *error = nil;
        [query fetch:&error];
        if (error) {
            NCLogError(@"Fetch token error: %@", error);
            [self clearAuthData];
            return NO;
        }
        
        NSString *token = query.password;
        if (token == nil || token.length <= 0) {
            [self clearAuthData];
            return NO;
        }
        self.authentication.accessToken = token;
        self.authentication.expirationDate = expirationDate;
        self.authentication.userID = userID;
        self.accessToken = token;
        return YES;
    }
    return NO;
}

- (void)clearAuthData {
    // Delete authentication from NSUserDefault
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NCWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Delete from keychain
    SAMKeychainQuery *query = [[SAMKeychainQuery alloc] init];
    query.service = NCWEIBO_KEYCHAINSERVICE;
    query.account = NCWEIBO_KEYCHAINACCOUNT;
    
    NSError *error = nil;
    [query deleteItem:&error];
    if (error) {
        NCLogError(@"Delete token error: %@", error);
    } else {
        NCLogInfo(@"Auth data deleted.");
    }
}

- (void)storeAuthData {
    // Save authentication to NSUserDefault
    NSDictionary *authData = @{
                               @"UserID": self.authentication.userID,
                               @"ExpirationDate": self.authentication.expirationDate,
                               @"AppKey": self.appKey
                               };
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"NCWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Save access token to Keychain
    SAMKeychainQuery *query = [[SAMKeychainQuery alloc] init];
    query.service = NCWEIBO_KEYCHAINSERVICE;
    query.account = NCWEIBO_KEYCHAINACCOUNT;
    query.password = self.accessToken;

    NSError *error = nil;
    [query save:&error];
    if (error) {
        NCLogError(@"Save token error: %@", error);
    } else {
        NCLogInfo(@"Auth data saved.");
    }
}

#pragma mark -
#pragma mark WeiboSDKDelegate

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    NSLog(@"Received Weibo request: %@", request);
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    NSLog(@"Received Weibo response: %@", response);
    
    //
    if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        if (response.statusCode == WeiboSDKResponseStatusCodeUserCancel) {
            if (_authCancellationBlock != nil) {
                _authCancellationBlock(self.authentication);
            }
        } else if (response.statusCode < WeiboSDKResponseStatusCodeSuccess) {
            if (_authCompletionBlock != nil) {
                NSString *error_description = @"Failed from WeiboSDK. See WeiboSDKResponseStatusCode for details.";
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: error_description};
                NSError *error = [NSError errorWithDomain:NCWEIBO_ERRORDOMAIN_WEIBOSDK
                                                     code:response.statusCode
                                                 userInfo:userInfo];
                _authCompletionBlock(NO, self.authentication, error);
            }
        } else {
            WBAuthorizeResponse *res = (WBAuthorizeResponse *)response;
            [self processSuccessfulAuthorizeResponse:res];
        }
    }
}

@end
