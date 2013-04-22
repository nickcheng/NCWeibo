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
    [self processSuccessHandlerWithRequestOperation:operation andResponseObject:responseObject andHandler:handler];
  };
}

- (void)processSuccessHandlerWithRequestOperation:(AFHTTPRequestOperation *)operation andResponseObject:(id)responseObject andHandler:(NCWeiboClientCompletionBlock)handler {
  //
  NSLog(@"%@", operation.request.allHTTPHeaderFields);
  
  //
  if (handler)
    handler(operation, responseObject, nil);
}

- (AFNetworkingFailureBlock)failureHandlerForClientHandler:(NCWeiboClientCompletionBlock)handler {
  return ^(AFHTTPRequestOperation *operation,  NSError *error) {
//    NSLog(@"%@", operation.request.allHTTPHeaderFields);
    NCWeiboErrorResponse *errorResponse = [[NCWeiboErrorResponse alloc] initWithJson:error.userInfo[NSLocalizedRecoverySuggestionErrorKey]];

    // Check error code. If code means token expired, call expired block.
//    errorResponse.errorCode = 21327; // Test code. Remove this when release.
    if (errorResponse && errorResponse.errorCode == 21327) {
      NSLog(@"Auth Token expired. Will call accessTokenExpiredHandler.");
      if (self.accessTokenExpiredHandler)
        self.accessTokenExpiredHandler(self.originalAPICallBlock);
    }

    //
    if (handler) {
      handler(operation, errorResponse, error);
    }
  };
}

- (void)doAuthBeforeCallAPI:(APIHandlerBlock)apiHandler andAuthErrorProcess:(NCWeiboClientCompletionBlock)completionHandler {
  if (!self.isAuthenticated) {
    self.originalAPICallBlock = apiHandler;
    if (self.authentication && self.authViewController) {
      [self authenticateWithCompletion:^(BOOL success, NCWeiboAuthentication *authentication, NSError *error) {
        if (success) {
          if (apiHandler)
            apiHandler();
        } else {
          NCWeiboErrorResponse *errorResponse = [[NCWeiboErrorResponse alloc] initWithJson:error.userInfo[NSLocalizedRecoverySuggestionErrorKey]];
          completionHandler(nil, errorResponse, error);
        }
      } andCancellation:nil]; // If you need to do sth in cancellation, use authenticateWithCompletion yourself.
    }
  } else {
    apiHandler();
  }
}

@end
