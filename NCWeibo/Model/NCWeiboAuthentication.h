//
//  NCWeiboAuthorize.h
//  NCWeibo
//
//  Created by nickcheng on 13-3-31.
//  Copyright (c) 2013年 NC. All rights reserved.
//

@class NCWeiboUser;

@interface NCWeiboAuthentication : NSObject

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSDate *expirationDate;

@property (nonatomic, strong) NCWeiboUser *user; // This property is for convenience. It will be nil unless you done authentication.

@end
