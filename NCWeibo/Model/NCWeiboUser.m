//
//  NCWeiboUser.m
//  Example
//
//  Created by nickcheng on 13-4-17.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "NCWeiboUser.h"

@implementation NCWeiboUser {
  NSString *_userId;
  NSString *_screenName;
  NSString *_name;
  NSString *_province;
  NSString *_city;
  NSString *_location;
  NSString *_description;
  NSString *_url;
  NSString *_profileImageUrl;
  NSString *_profileLargeImageUrl;
  NSString *_profileUrl;
  NSString *_domain;
  NSString *_weihao;
  NCWeiboUserGender _gender;
  int _followersCount;
  int _friendsCount;
  int _statusesCount;
  int _favoritesCount;
  NSDate *_createdAt;
  BOOL _following; // not supported by Sina
  BOOL _allowAllActMsg;
  BOOL _geoEnabled;
  BOOL _verified;
  int _verifiedType; // not supported by Sina
  NSString *_remark;
  BOOL _allowAllComment;
  NSString *_verifiedReason;
  BOOL _followMe;
  NCWeiboUserOnlineStatus _onlineStatus;
  int _biFollowersCount;
  NSString *_lang;
  int _star;
  int _mbtype;
  int _mbrank;
  int _blockWord;
}

@synthesize userId = _userId;
@synthesize screenName = _screenName;
@synthesize name = _name;
@synthesize province = _province;
@synthesize city = _city;
@synthesize location = _location;
@synthesize description = _description;
@synthesize url = _url;
@synthesize profileImageUrl = _profileImageUrl;
@synthesize profileLargeImageUrl = _profileLargeImageUrl;
@synthesize profileUrl = _profileUrl;
@synthesize domain = _domain;
@synthesize weihao = _weihao;
@synthesize gender = _gender;
@synthesize followersCount = _followersCount;
@synthesize friendsCount = _friendsCount;
@synthesize statusesCount = _statusesCount;
@synthesize favoritesCount = _favoritesCount;
@synthesize createdAt = _createdAt;
@synthesize following = _following; // not supported by Sina
@synthesize allowAllActMsg = _allowAllActMsg;
@synthesize geoEnabled = _geoEnabled;
@synthesize verified = _verified;
@synthesize verifiedType = _verifiedType; // not supported by Sina
@synthesize remark = _remark;
@synthesize allowAllComment = _allowAllComment;
@synthesize verifiedReason = _verifiedReason;
@synthesize followMe = _followMe;
@synthesize onlineStatus = _onlineStatus;
@synthesize biFollowersCount = _biFollowersCount;
@synthesize lang = _lang;
@synthesize star = _star;
@synthesize mbtype = _mbtype;
@synthesize mbrank = _mbrank;
@synthesize blockWord = _blockWord;

- (id)initWithJSONString:(NSString *)jsonString {
  //
	if((self = [super init]) == nil) return nil;
  
  // Custom initialization
  NSError *jsonError;
  NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&jsonError];
  if (jsonError) {
    NSLog(@"Generate JSONDict Error: %@", jsonError);
    return nil;
  }
  
  // 
  _userId = jsonDict[@"idstr"];
  _screenName = jsonDict[@"screen_name"];
  _name = jsonDict[@"name"];
  _province = jsonDict[@"province"];
  _city = jsonDict[@"city"];
  _location = jsonDict[@"location"];
  _description = jsonDict[@"description"];
  _url = jsonDict[@"url"];
  _profileImageUrl = jsonDict[@"profile_image_url"];
  _profileLargeImageUrl = jsonDict[@"avatar_large"];
  _profileUrl = jsonDict[@"profile_url"];
  _domain = jsonDict[@"domain"];
  _weihao = jsonDict[@"weihao"];
  _gender = [jsonDict[@"gender"] isEqual:@"m"] ? NCWeiboUserGenderMale : ([jsonDict[@"gender"] isEqual:@"f"] ? NCWeiboUserGenderFemale : NCWeiboUserGenderUnknow);
  _followersCount = [jsonDict[@"followers_count"] intValue];
  _friendsCount = [jsonDict[@"friends_count"] intValue];
  _statusesCount = [jsonDict[@"statuses_count"] intValue];
  _favoritesCount = [jsonDict[@"favourites_count"] intValue];
  _createdAt = [self dateFromString:jsonDict[@"created_at"]];
  _following = [jsonDict[@"following"] boolValue];
  _allowAllActMsg = [jsonDict[@"allow_all_act_msg"] boolValue];
  _geoEnabled = [jsonDict[@"geo_enabled"] boolValue];
  _verified = [jsonDict[@"verified"] boolValue];
  _verifiedType = [jsonDict[@"verified_type"] intValue];
  _remark = jsonDict[@"remark"];
  _allowAllComment = [jsonDict[@"allow_all_comment"] boolValue];
  _verifiedReason = jsonDict[@"verified_reason"];
  _followMe = [jsonDict[@"follow_me"] boolValue];
  _onlineStatus = [jsonDict[@"online_status"] intValue];
  _biFollowersCount = [jsonDict[@"bi_followers_count"] intValue];
  _lang = jsonDict[@"lang"];
  _star = [jsonDict[@"star"] intValue];
  _mbtype = [jsonDict[@"mbtype"] intValue];
  _mbrank = [jsonDict[@"mbrank"] intValue];
  _blockWord = [jsonDict[@"block_word"] intValue];
  
  return self;
}

- (NSDate *)dateFromString:(NSString *)dateString {
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  dateFormatter.dateFormat = @"EEE MMM dd HH:mm:ss ZZZ yyyy"; //Tue Oct 20 12:50:25 +0800 2009
  dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
  
  return [dateFormatter dateFromString:dateString];
}

@end
