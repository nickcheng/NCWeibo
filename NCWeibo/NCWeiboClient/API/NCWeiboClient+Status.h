//
//  NCWeiboClient+Status.h
//  NCWeibo
//
//  Created by nickcheng on 13-3-28.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "NCWeiboClient+HandlerBlocks.h"

@interface NCWeiboClient (Status)

- (void)createStatusWithText:(NSString *)text andImage:(UIImage *)image completion:(NCWeiboClientCompletionBlock)completionHandler;

@end
