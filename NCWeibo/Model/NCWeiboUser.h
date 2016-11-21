//
//  NCWeiboUser.h
//
//  Created by nickcheng on 13-4-17.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboUser.h"


@class WeiboUser;

@interface NCWeiboUser : NSObject

@property (nonatomic) WeiboUser *weiboUser;

@property (nonatomic) int extFlag;
@property (nonatomic) NSString *extInfo;

- (id)initWithWeiboUser:(WeiboUser *)weiboUser;

@end
