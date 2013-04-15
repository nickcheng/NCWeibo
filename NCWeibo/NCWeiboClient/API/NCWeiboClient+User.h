//
//  NCWeiboClient+User.h
//  NCWeibo
//
//  Created by nickcheng on 13-3-28.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "NCWeiboClient+HandlerBlocks.h"

@interface NCWeiboClient (User)

- (void)followWithID:(NSString *)userId completion:(NCWeiboClientCompletionBlock)completionHandler;

@end
