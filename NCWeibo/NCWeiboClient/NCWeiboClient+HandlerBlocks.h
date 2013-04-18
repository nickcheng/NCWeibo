//
//  NCWeiboClient+HandlerBlocks.h
//  NCWeibo
//
//  Created by nickcheng on 13-3-28.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "NCWeiboClient.h"

@class NCWeiboErrorResponse;

typedef void (^AFNetworkingSuccessBlock)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^AFNetworkingFailureBlock)(AFHTTPRequestOperation *operation, NSError *error);

typedef void (^NCWeiboClientCompletionBlock)(AFHTTPRequestOperation *operation, id responseObject, NSError *error);
typedef void (^APIHandlerBlock)();

@interface NCWeiboClient (HandlerBlocks)

- (AFNetworkingSuccessBlock)successHandlerForClientHandler:(NCWeiboClientCompletionBlock)handler;
- (AFNetworkingFailureBlock)failureHandlerForClientHandler:(NCWeiboClientCompletionBlock)handler;
- (void)processSuccessHandlerWithRequestOperation:(AFHTTPRequestOperation *)operation andResponseObject:(id)responseObject andHandler:(NCWeiboClientCompletionBlock)handler;

- (void)doAuthBeforeCallAPI:(APIHandlerBlock)apiHandler;

@end
