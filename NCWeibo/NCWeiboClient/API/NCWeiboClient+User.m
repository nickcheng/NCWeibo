//
//  NCWeiboClient+User.m
//  NCWeibo
//
//  Created by nickcheng on 13-3-28.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "NCWeiboClient+User.h"
#import "NCWeiboAuthentication.h"

@implementation NCWeiboClient (User)

- (void)followWithID:(NSString *)userId completion:(NCWeiboClientCompletionBlock)completionHandler {
  NSDictionary *params = @{
                           @"uid": userId
                           };
  [self postPath:@"friendships/create.json"
      parameters:params
         success:[self successHandlerForClientHandler:completionHandler]
         failure:[self failureHandlerForClientHandler:completionHandler]];

}

@end
