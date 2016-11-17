//
//  CustomModule.m
//  smarttv
//
//  Created by BanDouMacmini-1 on 2016/10/31.
//  Copyright © 2016年 WHY. All rights reserved.
//

#import "CustomModule.h"

#import <WeexSDK/WXBaseViewController.h>
#import "Constants.h"
#import "UserDefault.h"
#import "AppDelegate.h"

#import "WXViewController.h"

@implementation CustomModule

@synthesize weexInstance;

WX_EXPORT_METHOD(@selector(openURL:withParam:))
- (void)openURL:(NSString *)url withParam:(NSDictionary *)param
{
    NSString *newURL = url;
    if ([url hasPrefix:@"//"]) {
        newURL = [NSString stringWithFormat:@"http:%@", url];
    } else if (![url hasPrefix:@"http"]) {
#ifdef DEVELOP_DEMO
        NSString *host = [[NSUserDefaults standardUserDefaults] stringForKey:@"host"];
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/", host];
        newURL = [NSURL URLWithString:url relativeToURL:[NSURL URLWithString:urlStr]].absoluteString;
#else
        //        relative path
        //        NSString *host = [NSString stringWithFormat:@"http://%@:%@/", weexInstance.scriptURL.host, weexInstance.scriptURL.port];
        newURL = [NSURL URLWithString:url relativeToURL:[NSURL URLWithString:SERVER]].absoluteString;
#endif
    }
    
    WXViewController *controller = [[WXViewController alloc] init];
    controller.url = [NSURL URLWithString:newURL];
    if (param) {
        if ([param objectForKey:@"operate"]) {
            NSString *operate = param[@"operate"];
            //            if ([operate isEqualToString:@"login"]) {
            //                LoginController *login = [[LoginController alloc] init];
            //                login.param = param;
            //                login.url = [NSURL URLWithString:newURL];
            //                [weexInstance.viewController presentViewController:[[UINavigationController alloc] initWithRootViewController:login]
            //                                                          animated:YES
            //                                                        completion:nil];
            //                return;
            //            }
            //            else if ([operate isEqualToString:@"main"]) {
            //                AppDelegate *d = (AppDelegate *)[UIApplication sharedApplication].delegate;
            //                if ([param objectForKey:@"selected"]) {
            //                    [d gotoMainWithIndex:[param[@"selected"] integerValue]];
            //                } else {
            //                    [d gotoMainWithIndex:0];
            //                }
            //                return;
            //            }
            //            else if([operate isEqualToString:@"guide_detail"]) {
            //                SplashDetailController *splashDetail = [[SplashDetailController alloc] init];
            //                splashDetail.param = param;
            //                splashDetail.url = [NSURL URLWithString:newURL];
            //                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:splashDetail];
            //                AppDelegate *d = (AppDelegate *)[UIApplication sharedApplication].delegate;
            //                [d gotoSplashDetail:nav];
            //                return;
            //            }
            //            else if([operate isEqualToString:@"web"]) {
            //                WebController *controller = [[WebController alloc] init];
            //                controller.url = [NSURL URLWithString:newURL];
            //                [[weexInstance.viewController navigationController] pushViewController:controller animated:YES];
            //                return;
            //            }
            //        }
            //        else if ([param objectForKey:@"searchType"]) {
            //            SearchController *controller = [[SearchController alloc] init];
            //            NSURL *url = [NSURL URLWithString:newURL];
            //            controller.url = url;
            //            controller.param = param;
            //            [[weexInstance.viewController navigationController] pushViewController:controller animated:YES];
            //            return;
        }
        else {
            controller.param = param;
        }
    }
    [[weexInstance.viewController navigationController] pushViewController:controller animated:YES];
}

WX_EXPORT_METHOD(@selector(toBack:))
- (void)toBack:(NSDictionary *)param {
    if (param && [param objectForKey:@"toBackFlag"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:param[@"toBackFlag"] object:param userInfo:nil];
    }
    if ([weexInstance.viewController isKindOfClass:[WXViewController class]]) {
        [((WXViewController *)weexInstance.viewController) toBack:param[@"toBackFlag"]];
    }
}

WX_EXPORT_METHOD(@selector(setTabIndex:))
- (void)setTabIndex:(int)index {
//    if ([weexInstance.viewController isKindOfClass:[TopViewController class]]) {
//        [((TopViewController *)weexInstance.viewController) setTitleWithIndex:index];
//    }
}

WX_EXPORT_METHOD(@selector(regNavTitle:callBack:))
- (void)regNavTitle:(NSDictionary *)param callBack:(WXModuleCallback)callback {
    if ([weexInstance.viewController isKindOfClass:[WXViewController class]]) {
        [(WXViewController *)weexInstance.viewController regNavTitle:param callBack:callback];
    }
}

WX_EXPORT_METHOD(@selector(setNavTitle:))
- (void)setNavTitle:(NSDictionary *)param {
    if ([weexInstance.viewController isKindOfClass:[WXViewController class]]) {
        [(WXViewController *)weexInstance.viewController setNavTitle:param];
    }
}

WX_EXPORT_METHOD(@selector(phoneCall:))
- (void)phoneCall:(NSDictionary *)param {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:"]]) {
            NSString *tel = [NSString stringWithFormat:@"tel:%@", [param[@"phone"]
                                                                   stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tel]];
        }
    });
}

WX_EXPORT_METHOD(@selector(setKeyValue:value:))
- (void)setKeyValue:(NSString *)key value:(NSString *)value {
    [[UserDefault instance] setValue:value forKey:key];
}

WX_EXPORT_METHOD(@selector(getKeyValue:value:callBack:))
- (void)getKeyValue:(NSString *)key value:(NSString *)value callBack:(WXModuleCallback)callback {
    NSString *localValue = [[UserDefault instance] getValueForKey:key];
    if (!localValue) {
        localValue = value;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        callback(localValue);
    });
}

WX_EXPORT_METHOD(@selector(pickImage:callBack:))
- (void)pickImage:(NSDictionary *)param callBack:(WXModuleCallback)callback {
    if ([weexInstance.viewController isKindOfClass:[WXViewController class]]) {
        [(WXViewController *)weexInstance.viewController pickImageWithParam:param
                                                                   callBack:callback];
    }
}

WX_EXPORT_METHOD(@selector(pickDate:callBack:))
- (void)pickDate:(NSDictionary *)param callBack:(WXModuleCallback)callback {
    if ([weexInstance.viewController isKindOfClass:[WXViewController class]]) {
        [(WXViewController *)weexInstance.viewController pickDateWithParam:param
                                                                  callBack:callback];
    }
}

WX_EXPORT_METHOD(@selector(getLocation:callBack:))
- (void)getLocation:(NSDictionary *)param callBack:(WXModuleCallback)callback {
    if ([weexInstance.viewController isKindOfClass:[WXViewController class]]) {
        [(WXViewController *)weexInstance.viewController getLocationWithParam:param
                                                                     callBack:callback];
    }
}

WX_EXPORT_METHOD(@selector(pay:callBack:))
- (void)pay:(NSDictionary *)param callBack:(WXModuleCallback)callback {
    if ([weexInstance.viewController isKindOfClass:[WXViewController class]]) {
        [(WXViewController *)weexInstance.viewController payWithParam:param
                                                             callBack:callback];
    }
}

WX_EXPORT_METHOD(@selector(setToBackFlag:))
- (void)setToBackFlag:(NSString *)flag {
    if ([weexInstance.viewController isKindOfClass:[WXViewController class]]) {
        [(WXViewController *)weexInstance.viewController setToBackFlag:flag];
    }
}

WX_EXPORT_METHOD(@selector(startProgress:))
- (void)startProgress:(NSString *)text {
    if ([weexInstance.viewController isKindOfClass:[WXViewController class]]) {
        [(WXViewController *)weexInstance.viewController showProgress:text];
    }
}

WX_EXPORT_METHOD(@selector(stopProgress))
- (void)stopProgress {
    if ([weexInstance.viewController isKindOfClass:[WXViewController class]]) {
        [(WXViewController *)weexInstance.viewController hideProgress];
    }
}

WX_EXPORT_METHOD(@selector(dismissModal))
- (void)dismissModal {
    if ([weexInstance.viewController isKindOfClass:[WXViewController class]]) {
        [(WXViewController *)weexInstance.viewController dismissModal];
    }
}

@end
