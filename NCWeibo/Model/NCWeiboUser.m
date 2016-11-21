//
//  NCWeiboUser.m
//  Example
//
//  Created by nickcheng on 13-4-17.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "NCWeiboUser.h"


@implementation NCWeiboUser

- (id)initWithWeiboUser:(WeiboUser *)weiboUser {
    self = [super init];
    if (self == nil) return nil;
    
    // Custom initialization
    _weiboUser = weiboUser;
    _extFlag = 0;
    _extInfo = @"";
    
    return self;
}

@end
