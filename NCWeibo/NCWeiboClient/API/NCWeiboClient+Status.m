//
//  NCWeiboClient+Status.m
//  NCWeibo
//
//  Created by nickcheng on 13-3-28.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "NCWeiboClient+Status.h"
#import "NCWeiboClientConfig.h"

@implementation NCWeiboClient (Status)

- (void)createStatusWithText:(NSString *)text andImage:(UIImage *)image completion:(NCWeiboClientCompletionBlock)completionHandler {
  if (!image) {
    [self createTextStatusWithText:text completion:completionHandler];
  } else {
    [self createImageStatusWithImage:image andText:text completion:completionHandler];
  }
}

- (void)createTextStatusWithText:(NSString *)text completion:(NCWeiboClientCompletionBlock)completionHandler {
  [self doAuthBeforeCallAPI:^{
    NSDictionary *params = @{
                             @"status": text,
                             };
    [self postPath:@"statuses/update.json"
        parameters:params
           success:[self successHandlerForClientHandler:completionHandler]
           failure:[self failureHandlerForClientHandler:completionHandler]];
  } andAuthErrorProcess:completionHandler];
}

- (void)createImageStatusWithImage:(UIImage *)image andText:(NSString *)text completion:(NCWeiboClientCompletionBlock)completionHandler {
  [self doAuthBeforeCallAPI:^{
    NSDictionary *params = @{
                             @"status": text,
                             };
    
    NSMutableURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:@"statuses/upload.json" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
      NSData *data = UIImageJPEGRepresentation(image, .8f);
      [formData appendPartWithFileData:data name:@"pic" fileName:NCWEIBO_UPLOADIMAGENAME mimeType:@"image/jpeg"];
    }];
		
    AFHTTPRequestOperation *requestOperation = [self HTTPRequestOperationWithRequest:request
                                                                             success:[self successHandlerForClientHandler:completionHandler]
                                                                             failure:[self failureHandlerForClientHandler:completionHandler]];
    //  [requestOperation setUploadProgressBlock:progressHandler];
    [self enqueueHTTPRequestOperation:requestOperation];
  } andAuthErrorProcess:completionHandler];
}

@end
