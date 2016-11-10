//
//  NCWeiboClient+HandlerBlocks.m
//  NCWeibo
//
//  Created by nickcheng on 13-3-28.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "NCWeiboClient+HandlerBlocks.h"
#import "NCWeiboErrorResponse.h"
#import "NCWeiboClientConfig.h"


@implementation NCWeiboClient (HandlerBlocks)

- (void)processRequestCompletion:(WBHttpRequest *)httpRequest result:(id)result error:(NSError *)error handler:(NCWeiboClientCompletionBlock)handler {
    if (error) {
        NCLogError(@"Request:%@ \n Error:%@", httpRequest, error);
        if (handler) {
            handler(result, error);
        }
    } else {
        NCLogInfo(@"Request:%@", httpRequest);
        if (handler) {
            handler(result, nil);
        }
    }
}

- (void)doAuthBeforeCallAPI:(APIHandlerBlock)apiHandler andAuthErrorProcess:(NCWeiboClientCompletionBlock)completionHandler {
    if (!self.isAuthenticated) {
        self.originalAPICallBlock = apiHandler;
        if (self.authentication && self.authViewController) {
            [self authenticateWithCompletion:^(BOOL success, NCWeiboAuthentication *authentication, NSError *error) {
                if (success) {
                    if (apiHandler != nil)
                        apiHandler();
                } else {
                    NCWeiboErrorResponse *errorResponse = [[NCWeiboErrorResponse alloc] initWithJson:error.userInfo[NSLocalizedRecoverySuggestionErrorKey]];
                    completionHandler(nil, errorResponse, error);
                }
            } andCancellation:nil]; // If you need to do sth in cancellation, use authenticateWithCompletion yourself.
        } else {
            if (completionHandler != nil) {
                NSError *error = [NSError errorWithDomain:NCWEIBO_ERRORDOMAIN_OAUTH2 code:400 userInfo:@{NSLocalizedDescriptionKey:@"NCWeibo.Auth.NoAuthInfo"}];
                completionHandler(nil, nil, error);
            }
        }
    } else {
        apiHandler();
    }
}

@end
