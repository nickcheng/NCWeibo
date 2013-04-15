//
//  NCWeiboErrorResponse.m
//  Example
//
//  Created by nickcheng on 13-4-14.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "NCWeiboErrorResponse.h"

@implementation NCWeiboErrorResponse {
  NSString *_errorMessage;
  NSInteger _errorCode;
}

@synthesize errorMessage = _errorMessage;
@synthesize errorCode = _errorCode;

- (id)initWithJson:(NSString *)json {
  //
	if((self = [super init]) == nil) return nil;
  
  // Custom initialization
  NSError *jsonError;
  NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&jsonError];
  if (!jsonError) {
    _errorMessage = result[@"error"];
    _errorCode = [result[@"error_code"] intValue];
  }
  else
    return nil;
  
  return self;
}

@end
