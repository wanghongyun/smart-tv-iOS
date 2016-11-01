//
//  UserDefault.m
//  bandou-weex
//
//  Created by BanDouMacmini-1 on 16/8/20.
//  Copyright © 2016年 WHY. All rights reserved.
//

#import "UserDefault.h"

@interface UserDefault()


@end

@implementation UserDefault

+ (instancetype)instance {
    static UserDefault *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UserDefault alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // TODO:
    }
    return self;
}

- (void)clear {
    // TODO;
}

- (void)setValue:(NSString *)value forKey:(NSString *)key {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:value forKey:key];
    [def synchronize];
}

- (NSString *)getValueForKey:(NSString *)key {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    return [def stringForKey:key];
}

- (void)setLocalVersion:(NSString *)version {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:version forKey:@"local_version"];
    [def synchronize];
}

- (NSString *)localVersion {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    return [def stringForKey:@"local_version"];
}

@end
