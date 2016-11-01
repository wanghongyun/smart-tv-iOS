//
//  UserDefault.h
//  bandou-weex
//
//  Created by BanDouMacmini-1 on 16/8/20.
//  Copyright © 2016年 WHY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefault : NSObject

+ (instancetype)instance;

- (void)setValue:(NSString *)value forKey:(NSString *)key;
- (NSString *)getValueForKey:(NSString *)key;
- (NSString *)localVersion;
- (void)setLocalVersion:(NSString *)version;

@end
