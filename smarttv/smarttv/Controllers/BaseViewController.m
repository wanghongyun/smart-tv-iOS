//
//  BaseViewController.m
//  bandou-weex
//
//  Created by BanDouMacmini-1 on 16/8/11.
//  Copyright © 2016年 WHY. All rights reserved.
//

#import "BaseViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "MBProgressHUD.h"

@interface BaseViewController() <UIGestureRecognizerDelegate>

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBarHidden = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
}

- (void)showProgress:(NSString *)text {
    [MBProgressHUD hideAllHUDForView:self.view];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    if (text) {
        hud.label.text = text;
    } else {
        hud.label.text = @"加载中...";
    }
}

-(void)hideProgress {
    [[MBProgressHUD getHUDForView:self.view] hideAnimated:YES];
}

-(void)showToastWithText:(NSString *)text {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // Set the annular determinate mode to show task progress.
    hud.mode = MBProgressHUDModeText;
    hud.label.text = text;
    // Move to bottm center.
    hud.offset = CGPointMake(0.0, MBProgressMaxOffset);
    [hud hideAnimated:YES afterDelay:2.0];
}

@end
