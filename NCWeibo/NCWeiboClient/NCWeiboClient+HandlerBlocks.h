//
//  NCWeiboClient+HandlerBlocks.h
//  NCWeibo
//
//  Created by nickcheng on 13-3-28.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "NCWeiboClient.h"

@class NCWeiboErrorResponse, WBHttpRequest;

typedef void (^NCWeiboClientCompletionBlock)(id responseObject, NSError *error);
typedef void (^APIHandlerBlock)();

@interface NCWeiboClient (HandlerBlocks)

- (void)processRequestCompletion:(WBHttpRequest *)httpRequest result:(id)result error:(NSError *)error handler:(NCWeiboClientCompletionBlock)handler;

- (void)doAuthBeforeCallAPI:(APIHandlerBlock)apiHandler andAuthErrorProcess:(NCWeiboClientCompletionBlock)completionHandler;

@end
