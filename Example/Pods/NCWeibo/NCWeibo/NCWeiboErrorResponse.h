//
//  NCWeiboErrorResponse.h
//  Example
//
//  Created by nickcheng on 13-4-14.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCWeiboErrorResponse : NSObject

@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic, assign) NSInteger errorCode;

- (id)initWithJson:(NSString *)json;

@end
