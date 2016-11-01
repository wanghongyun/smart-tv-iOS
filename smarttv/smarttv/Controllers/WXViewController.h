//
//  WXViewController.h
//  bandou-weex
//
//  Created by BanDouMacmini-1 on 16/8/11.
//  Copyright © 2016年 WHY. All rights reserved.
//

#import "BaseViewController.h"
#import <WeexSDK/WXModuleProtocol.h>

@interface WXViewController : BaseViewController

@property (nonatomic, strong) WXSDKInstance *instance;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSDictionary *param;
@property (nonatomic, copy) WXModuleCallback titleCallback;

- (void)render;

- (void)setNavTitle:(NSDictionary *)param;
- (void)regNavTitle:(NSDictionary *)param callBack:(WXModuleCallback)callback;
- (void)pickImageWithParam:(NSDictionary *)param callBack:(WXModuleCallback)callback;
- (void)pickDateWithParam:(NSDictionary *)param callBack:(WXModuleCallback)callback;
- (void)getLocationWithParam:(NSDictionary *)param callBack:(WXModuleCallback)callback;
/// param: {type: ali/wexin, param:{...}}
- (void)payWithParam:(NSDictionary *)param callBack:(WXModuleCallback)callback;
- (void)setToBackFlag:(NSString *)flag;
- (void)toBack:(NSString *)flag;
- (void)didReceiveTobackNotification:(NSNotification *)notification;

- (void)dismissModal;

@end
