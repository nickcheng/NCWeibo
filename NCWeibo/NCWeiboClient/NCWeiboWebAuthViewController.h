//
//  NCWeiboWebAuthViewController.h
//  NCWeibo
//
//  Created by nickcheng on 13-3-31.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCWeiboClient.h"

@class NCWeiboAuthentication;

@interface NCWeiboWebAuthViewController : UIViewController

- (id)initWithAuthentication:(NCWeiboAuthentication *)authentication andCancellation:(NCWeiboAuthCancellationBlock)cancellation andCompletion:(NCWeiboAuthCompletionBlock)completion;

@end
