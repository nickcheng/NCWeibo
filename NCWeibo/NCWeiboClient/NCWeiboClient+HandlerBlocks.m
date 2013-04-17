//
//  NCWeiboClient+HandlerBlocks.m
//  NCWeibo
//
//  Created by nickcheng on 13-3-28.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "NCWeiboClient+HandlerBlocks.h"
#import "NCWeiboErrorResponse.h"

@implementation NCWeiboClient (HandlerBlocks)

- (AFNetworkingSuccessBlock)successHandlerForClientHandler:(NCWeiboClientCompletionBlock)handler {
  return ^(AFHTTPRequestOperation *operation, id responseObject) {
    //
    NSLog(@"%@", operation.request.allHTTPHeaderFields);

    //
    if (handler)
      handler(operation, responseObject, nil);
  };
}

- (AFNetworkingFailureBlock)failureHandlerForClientHandler:(NCWeiboClientCompletionBlock)handler {
  return ^(AFHTTPRequestOperation *operation,  NSError *error) {
    NSLog(@"%@", operation.request.allHTTPHeaderFields);
    NCWeiboErrorResponse *errorResponse = [[NCWeiboErrorResponse alloc] initWithJson:error.userInfo[NSLocalizedRecoverySuggestionErrorKey]];

    // Check error code. If code means token expired, call expired block.
//    errorResponse.errorCode = 21327; // Test code. Remove this when release.
    if (errorResponse && errorResponse.errorCode == 21327) {
      NSLog(@"Auth Token expired. Will call accessTokenExpiredHandler.");
      if (self.accessTokenExpiredHandler)
        self.accessTokenExpiredHandler();
    }

    //
    if (handler) {
      handler(operation, errorResponse, error);
    }
  };
}

- (void)doAuthBeforeCallAPI:(APIHandlerBlock)apiHandler {
  //
  if (!self.isAuthenticated) {
    // do oAuth
    if (self.authentication && self.authViewController) {
      [self authenticateWithCompletion:^(BOOL success, NCWeiboAuthentication *authentication, NSError *error) {
        //
        apiHandler();
      } andCancellation:^(NCWeiboAuthentication *authentication) {
        //
      }];
    }
  }
  else {
    apiHandler();
  }
}

@end
