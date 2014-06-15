//
//  NCWeiboClient+HandlerBlocks.h
//  NCWeibo
//
//  Created by nickcheng on 13-3-28.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "NCWeiboClient.h"

@class NCWeiboErrorResponse;

typedef void (^AFNetworkingSuccessBlock)(NSURLSessionDataTask *task, id responseObject);
typedef void (^AFNetworkingFailureBlock)(NSURLSessionDataTask *task, NSError *error);

typedef void (^NCWeiboClientCompletionBlock)(NSURLSessionDataTask *task, id responseObject, NSError *error);
typedef void (^APIHandlerBlock)();

@interface NCWeiboClient (HandlerBlocks)

- (AFNetworkingSuccessBlock)successHandlerForClientHandler:(NCWeiboClientCompletionBlock)handler;
- (AFNetworkingFailureBlock)failureHandlerForClientHandler:(NCWeiboClientCompletionBlock)handler;
- (void)processSuccessHandlerWithRequestOperation:(NSURLSessionDataTask *)operation andResponseObject:(id)responseObject andHandler:(NCWeiboClientCompletionBlock)handler;

- (void)doAuthBeforeCallAPI:(APIHandlerBlock)apiHandler andAuthErrorProcess:(NCWeiboClientCompletionBlock)completionHandler;

@end
