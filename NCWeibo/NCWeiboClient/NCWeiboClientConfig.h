//
//  WeiboOAuth2Config.h
//  NCWeibo
//
//  Created by nickcheng on 13-3-28.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#define NCWEIBO_APIBASEURL @"https://api.weibo.com/2/"
#define NCWEIBO_APPAUTHURL @"https://api.weibo.com/oauth2/authorize"
#define NCWEIBO_APPAUTHURL_IPHONE @"sinaweibosso://login"
#define NCWEIBO_APPAUTHURL_IPAD @"sinaweibohdsso://login"
#define NCWEIBO_ACCESSTOKENBASEURL @"https://api.weibo.com/oauth2"
#define NCWEIBO_ACCESSTOKENURL @"https://api.weibo.com/oauth2/access_token"
#define NCWEIBO_ERRORDOMAIN_OAUTH2 @"com.ncweibo.OAuth2"
#define NCWEIBO_ERRORDOMAIN_API @"com.ncweibo.api"
#define NCWEIBO_KEYCHAINSERVICE @"com.ncweibo"
#define NCWEIBO_KEYCHAINACCOUNT @"com.ncweibo"
#define NCWEIBO_USERAGENT @"NCWeibo"
#define NCWEIBO_UPLOADIMAGENAME @"ncweibo.jpg"
#define NCWEIBO_PAGESIZE 200

typedef enum
{
	NCWeiboErrorCodeParseError       = 200,
	NCWeiboErrorCodeSSOParamsError   = 202,
} NCWeiboErrorCode;

// Logging
#ifdef DDLogInfo
#define NCLogInfo(frmt, ...) DDLogInfo(frmt, ##__VA_ARGS__)
#else
#define NCLogInfo(frmt, ...) NSLog(frmt, ##__VA_ARGS__)
#endif

#ifdef DDLogWarn
#define NCLogWarn(frmt, ...) DDLogWarn(frmt, ##__VA_ARGS__)
#else
#define NCLogWarn(frmt, ...) NSLog(frmt, ##__VA_ARGS__)
#endif

#ifdef DDLogError
#define NCLogError(frmt, ...) DDLogError(frmt, ##__VA_ARGS__)
#else
#define NCLogError(frmt, ...) NSLog(frmt, ##__VA_ARGS__)
#endif
