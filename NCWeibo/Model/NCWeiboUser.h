//
//  NCWeiboUser.h
//
//  Created by nickcheng on 13-4-17.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  NCWeiboUserGenderUnknow = 0,
  NCWeiboUserGenderMale,
  NCWeiboUserGenderFemale,
} NCWeiboUserGender;

typedef enum {
  NCWeiboUserOnlineStatusOffline = 0,
  NCWeiboUserOnlineStatusOnline = 1,
} NCWeiboUserOnlineStatus;

@interface NCWeiboUser : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *screenName;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *province;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *profileImageUrl;
@property (nonatomic, strong) NSString *profileLargeImageUrl;
@property (nonatomic, strong) NSString *profileUrl;
@property (nonatomic, strong) NSString *domain;
@property (nonatomic, strong) NSString *weihao;
@property (nonatomic, assign) NCWeiboUserGender gender;
@property (nonatomic, assign) int followersCount;
@property (nonatomic, assign) int friendsCount;
@property (nonatomic, assign) int statusesCount;
@property (nonatomic, assign) int favoritesCount;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, assign) BOOL following; // not supported by Sina
@property (nonatomic, assign) BOOL allowAllActMsg;
@property (nonatomic, assign) BOOL geoEnabled;
@property (nonatomic, assign) BOOL verified;
@property (nonatomic, assign) int verifiedType; // not supported by Sina
@property (nonatomic, strong) NSString *remark;
//@property (nonatomic, strong) NCWeiboStatus *status;
@property (nonatomic, assign) BOOL allowAllComment;
@property (nonatomic, strong) NSString *verifiedReason;
@property (nonatomic, assign) BOOL followMe;
@property (nonatomic, assign) NCWeiboUserOnlineStatus onlineStatus;
@property (nonatomic, assign) int biFollowersCount;
@property (nonatomic, strong) NSString *lang;
@property (nonatomic, assign) int star;
@property (nonatomic, assign) int mbtype;
@property (nonatomic, assign) int mbrank;
@property (nonatomic, assign) int blockWord;

- (id)initWithJSONString:(NSString *)jsonString;

@end
