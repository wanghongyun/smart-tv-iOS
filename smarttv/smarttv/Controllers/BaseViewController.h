//
//  BaseViewController.h
//  bandou-weex
//
//  Created by BanDouMacmini-1 on 16/8/11.
//  Copyright © 2016年 WHY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

-(void)showProgress:(NSString *)text;
-(void)hideProgress;
-(void)showToastWithText:(NSString *)text;

@end
