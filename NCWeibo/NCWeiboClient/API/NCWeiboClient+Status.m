//
//  NCWeiboClient+Status.m
//  NCWeibo
//
//  Created by nickcheng on 13-3-28.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "NCWeiboClient+Status.h"
#import "NCWeiboClientConfig.h"
#import "WeiboSDK.h"


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
        [WBHttpRequest
         requestForShareAStatus:text
         contatinsAPicture:nil
         orPictureUrl:nil
         withAccessToken:self.accessToken
         andOtherProperties:nil
         queue:nil
         withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
             [self processRequestCompletion:httpRequest result:result error:error handler:completionHandler];
         }];
    } andAuthErrorProcess:completionHandler];
}

- (void)createImageStatusWithImage:(UIImage *)image andText:(NSString *)text completion:(NCWeiboClientCompletionBlock)completionHandler {
    [self doAuthBeforeCallAPI:^{
        WBImageObject *imageObject = [WBImageObject object];
        imageObject.imageData = UIImagePNGRepresentation(image);
        
        //
        [WBHttpRequest
         requestForShareAStatus:text
         contatinsAPicture:imageObject
         orPictureUrl:nil
         withAccessToken:self.accessToken
         andOtherProperties:nil
         queue:nil
         withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
             [self processRequestCompletion:httpRequest result:result error:error handler:completionHandler];
         }];
    } andAuthErrorProcess:completionHandler];
}

@end
