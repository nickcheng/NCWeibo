//
//  NCWeiboClient+User.m
//  NCWeibo
//
//  Created by nickcheng on 13-3-28.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "NCWeiboClient+User.h"
#import "NCWeiboAuthentication.h"
#import "NCWeiboUser.h"
#import "WeiboSDK.h"


@implementation NCWeiboClient (User)

- (void)fetchCurrentUserWithCompletion:(NCWeiboClientCompletionBlock)completionHandler {
    [self doAuthBeforeCallAPI:^{
        [self fetchUserWithID:self.authentication.userID completion:completionHandler];
    } andAuthErrorProcess:completionHandler];
}

- (void)fetchUserWithID:(NSString *)userID completion:(NCWeiboClientCompletionBlock)completionHandler {
    [self doAuthBeforeCallAPI:^{
        [WBHttpRequest
            requestForUserProfile:userID
            withAccessToken:self.accessToken
            andOtherProperties:nil
            queue:nil
            withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                if (error) {
                    [self processRequestCompletion:nil result:nil error:error handler:completionHandler];
                    return;
                }
                
                NCWeiboUser *user = [[NCWeiboUser alloc] initWithWeiboUser:result];
                [self processRequestCompletion:httpRequest result:user error:nil handler:completionHandler];
            }];
    } andAuthErrorProcess:completionHandler];
}

- (void)fetchUserWithName:(NSString *)screenName completion:(NCWeiboClientCompletionBlock)completionHandler {
    NSDictionary *params = @{
                             @"screen_name": screenName
                             };
    [self doAuthBeforeCallAPI:^{
        [WBHttpRequest
            requestForUserProfile:nil
            withAccessToken:self.accessToken
            andOtherProperties:params
            queue:nil
            withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                if (error) {
                    [self processRequestCompletion:nil result:nil error:error handler:completionHandler];
                    return;
                }
                
                NCWeiboUser *user = [[NCWeiboUser alloc] initWithWeiboUser:result];
                [self processRequestCompletion:httpRequest result:user error:nil handler:completionHandler];
            }];
    } andAuthErrorProcess:completionHandler];
}

- (void)followUser:(NCWeiboUser *)user completion:(NCWeiboClientCompletionBlock)completionHandler {
    return [self followUserWithID:user.weiboUser.userID completion:completionHandler];
}

- (void)followUserWithID:(NSString *)userID completion:(NCWeiboClientCompletionBlock)completionHandler {
    //
    [self doAuthBeforeCallAPI:^{
        [WBHttpRequest
            requestForFollowAUser:userID
            withAccessToken:self.accessToken
            andOtherProperties:nil
            queue:nil
            withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                [self processRequestCompletion:httpRequest result:result error:error handler:completionHandler];
            }];
    } andAuthErrorProcess:completionHandler];
}

@end
