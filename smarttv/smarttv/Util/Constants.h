//
//  Constants.h
//  TestWeex
//
//  Created by BanDouMacmini-1 on 16/8/10.
//  Copyright © 2016年 BanDouMacmini-1. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

/*
 * 开发模式，调用本地ip，本地server，不同的toBackFlag
 */
//#define DEVELOP_DEMO

#define HOST @"http://smarttv.webuildus.com/"

#define SERVER [NSString stringWithFormat:@"%@%@", HOST, @"smart-tv-weex/"]
#define TOP_VIEW [NSString stringWithFormat:@"%@%@", SERVER, @"dist/main.js"]
#define SPLASH_VIEW [NSString stringWithFormat:@"%@%@", SERVER, @"dist/guide.js"]

//应用注册scheme,在AlixPayDemo-Info.plist定义URL types
#define ALI_PAY_SCHEME @"bandoualipay"

#define ALI_PAY_NOTIFICATION @"ali_pay"

#define WEIXIN_PAY_NOTIFICATION @"weixin_pay"

#define WEIXIN_SCHEME @"wx29bf87bc736d6f33"

#ifndef DEVELOP_DEMO
    #define PROJECT @"smart-tv-weex/"
#else
    #define PROJECT @"/"
#endif

#endif /* Constants_h */
