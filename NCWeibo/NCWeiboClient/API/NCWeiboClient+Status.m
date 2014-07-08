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
    [self POST:@"statuses/update.json"
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
    /// This is standard way.
//    [self POST:@"statuses/upload.json"
//        parameters:params
//        constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//          NSData *data = UIImageJPEGRepresentation(image, 1.0);
//          [formData appendPartWithFileData:data
//                                      name:@"pic"
//                                  fileName:NCWEIBO_UPLOADIMAGENAME
//                                  mimeType:@"image/jpeg"];
//        }
//        success:[self successHandlerForClientHandler:completionHandler]
//        failure:[self failureHandlerForClientHandler:completionHandler]];
    
    /// Walkaround for Apple bug. See below link for details.
    /// @see https://github.com/AFNetworking/AFNetworking/issues/1398
    NSString* apiUrl = [[NSURL URLWithString:@"statuses/upload.json" relativeToURL:self.baseURL] absoluteString];
    
    // Prepare a temporary file to store the multipart request prior to sending it to the server due to an alleged
    // bug in NSURLSessionTask.
    NSString* tmpFilename = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
    NSURL* tmpFileUrl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:tmpFilename]];
    
    // Create a multipart form request.
    NSMutableURLRequest *multipartRequest =
      [self.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                   URLString:apiUrl
                                                  parameters:params
                                   constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                     NSData *data = UIImageJPEGRepresentation(image, 1.0);
                                     [formData appendPartWithFileData:data
                                                                 name:@"pic"
                                                             fileName:NCWEIBO_UPLOADIMAGENAME
                                                             mimeType:@"image/jpeg"];
                                   } error:nil];
    
    // Dump multipart request into the temporary file.
    [self.requestSerializer
        requestWithMultipartFormRequest:multipartRequest
        writingStreamContentsToFile:tmpFileUrl
        completionHandler:^(NSError *error) {
          // Once the multipart form is serialized into a temporary file, we can initialize
          // the actual HTTP request using session manager.
          
          // Create default session manager.
          AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
          
          // Show progress.
          NSProgress *progress = nil;
          
          // Here note that we are submitting the initial multipart request. We are, however,
          // forcing the body stream to be read from the temporary file.
          NSURLSessionUploadTask *uploadTask =
            [manager uploadTaskWithRequest:multipartRequest
                                  fromFile:tmpFileUrl
                                  progress:&progress
                         completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                           // Cleanup: remove temporary file.
                           [[NSFileManager defaultManager] removeItemAtURL:tmpFileUrl error:nil];
                           
                           // Do something with the result.
                           if (error) {
                             NCLogInfo(@"Error: %@", error);
                           } else {
                             NCLogInfo(@"Success: %@", responseObject);
                           }
                         }];
          
          // Add the observer monitoring the upload progress.
          [progress addObserver:self
                     forKeyPath:@"fractionCompleted"
                        options:NSKeyValueObservingOptionNew
                        context:NULL];
          
          // Start the file upload.
          [uploadTask resume];
        }];
  } andAuthErrorProcess:completionHandler];
}

@end
