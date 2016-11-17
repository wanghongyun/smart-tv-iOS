//
//  WXViewController.m
//  bandou-weex
//
//  Created by BanDouMacmini-1 on 16/8/11.
//  Copyright © 2016年 WHY. All rights reserved.
//

#import "WXViewController.h"
#import <WeexSDK/WeexSDK.h>
//#import "Connection.h"
#import "Constants.h"
#import "UIColor+Hex.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>

//#import "WXApi.h"
//#import <AlipaySDK/AlipaySDK.h>

#define ERROR_VIEW_TAG 1000
#define LOADING_VIEW_TAG 1001
#define WEEX_VIEW_TAG 1002

@interface WXViewController()<CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIView *weexView;
@property (nonatomic, assign) CGFloat weexHeight;

@property (nonatomic, copy) WXModuleCallback imageCallback;
@property (nonatomic, copy) WXModuleCallback locationCallback;
@property (nonatomic, copy) WXModuleCallback payCallback;

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation WXViewController

- (void)dealloc {
    [_instance destroyInstance];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _weexHeight = self.view.frame.size.height;
    
    if (self.param) {
        self.title = self.param[@"title"];
    }
    
    [self render];
    
    NSString *flag;
#ifdef DEVELOP_DEMO
    flag = [self.instance.scriptURL.path substringFromIndex:1];
#else 
    flag = [[self.instance.scriptURL.path componentsSeparatedByString:PROJECT] lastObject];
#endif
    if (flag) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTobackNotification:) name:flag object:nil];
    }
    NSLog(@"flag:\n%@", flag);

}

- (void)viewDidLayoutSubviews
{
    _weexHeight = self.view.frame.size.height;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(aliPayNotification:)
                                                 name:ALI_PAY_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(weixinPayNotification:)
                                                 name:WEIXIN_PAY_NOTIFICATION
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateInstanceState:WeexInstanceAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALI_PAY_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WEIXIN_PAY_NOTIFICATION object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self updateInstanceState:WeexInstanceDisappear];
    [self.locationManager stopUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showLoading {
    
    [self showProgress:nil];
    return;
    
    [[self.view viewWithTag:LOADING_VIEW_TAG] removeFromSuperview];
    
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 150.0, 200.0)];
    container.center = view.center;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((150.0 - 70.0) * 0.5, 0.0, 70.0, 70.0)];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"load_image" ofType:@"gif"]];
    [imageView sd_setImageWithURL:url];
    [container addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 70.0, 150.0, 30.0)];
    label.font = [UIFont systemFontOfSize:16.0];
    label.textColor = [UIColor colorWithWhite:0.58 alpha:1.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"正在加载请稍候...";
    [container addSubview:label];
    
    [view addSubview: container];
    view.backgroundColor = [UIColor whiteColor];
    view.tag = LOADING_VIEW_TAG;
    
    view.alpha = 0.0;
    [self.view addSubview: view];
    
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        view.alpha = 1.0;
    } completion:nil];
}

- (void)hideLoading {
    [self hideProgress];
    return;
    [[self.view viewWithTag:LOADING_VIEW_TAG] removeFromSuperview];
}

- (void)showError {
    return
    [[self.view viewWithTag:ERROR_VIEW_TAG] removeFromSuperview];
    
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 150.0, 200.0)];
    container.center = view.center;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((150.0 - 70.0) * 0.5, 0.0, 70.0, 70.0)];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"error_image" ofType:@"gif"]];
    [imageView sd_setImageWithURL:url];
    [container addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 70.0, 150.0, 40.0)];
    label.font = [UIFont systemFontOfSize:14.0];
    label.textColor = [UIColor colorWithWhite:0.58 alpha:1.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 2;
    label.text = @"页面太惊艳\n网络都塞车了!";
    
    [container addSubview:label];
    
    CGRect frame = label.frame;
    frame.origin.y = frame.origin.y + frame.size.height;
    frame.size.height = 20.0;
    
    UIButton *refresh = [UIButton buttonWithType:UIButtonTypeCustom];
    refresh.frame = frame;
    refresh.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [refresh setTitle:@"刷新" forState:UIControlStateNormal];
    UIColor *blueColor = [UIColor colorWithRed:62.0/255.0 green:195.0/255.0 blue:214.0/255.0 alpha:1.0];
    [refresh setTitleColor:blueColor forState:UIControlStateNormal];
    [refresh addTarget:self action:@selector(render) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:refresh];
    
    [view addSubview: container];
    view.backgroundColor = [UIColor whiteColor];
    view.tag = ERROR_VIEW_TAG;
    view.alpha = 0.0;
    [self.view addSubview: view];
    
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        view.alpha = 1.0;
    } completion:nil];
}

- (void)hideError {
    [[self.view viewWithTag:ERROR_VIEW_TAG] removeFromSuperview];
}

#pragma mark - notification

- (void)dismissModal {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)toBack:(NSString *)flag {
    if (flag && flag.length > 0) {
        for (UIViewController *c in self.navigationController.viewControllers) {
            if ([c isKindOfClass:[self class]]) {
                if ([((WXViewController *)c).instance.scriptURL.path containsString:flag]) {
                    [self.navigationController popToViewController:c animated:YES];
                    return;
                }
            }
        }
        AppDelegate *d = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [d gotoMainWithIndex:0];
        if ([d.window.rootViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *rootNav = (UINavigationController *)d.window.rootViewController;
            if (self.navigationController.viewControllers.firstObject != rootNav.viewControllers.firstObject) {
                [self dismissViewControllerAnimated:YES completion:nil];
                [d gotoMainWithIndex:0];
            } else {
                [d gotoMainWithIndex:0];
            }
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
            [d gotoMainWithIndex:0];
        }
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setToBackFlag:(NSString *)flag {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTobackNotification:) name:flag object:nil];
}

- (void)didReceiveTobackNotification:(NSNotification *)notification {
    if (notification.object && [notification.object isKindOfClass:[NSDictionary class]]) {
        if (notification.object && [notification.object objectForKey:@"param"]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:self.param];
            [dict addEntriesFromDictionary:[notification.object objectForKey:@"param"]];
            self.param = dict;
        }
        [self render];
    }
}

- (void)didLogin:(NSNotification *)notification {
    [self render];
}

- (void)didLogout:(NSNotification *)notification {
    [self render];
}

#pragma mark - nav right

- (void)regNavTitle:(NSDictionary *)param callBack:(WXModuleCallback)callback {
    self.titleCallback = callback;
}

- (void)setNavTitle:(NSDictionary *)param {
    if ([param objectForKey:@"rightTitle"]) {
        NSString *rightTitle = param[@"rightTitle"];
        UIButton *right = [UIButton buttonWithType:UIButtonTypeCustom];
        right.frame = CGRectMake(0.0, 0.0, 50.0, 44.0);
        right.titleLabel.font = [UIFont systemFontOfSize:14];
        [right setTitle:rightTitle forState:UIControlStateNormal];
        
        if ([param objectForKey:@"rightColor"]) {
            [right setTitleColor:[UIColor colorWithHexString:param[@"rightColor"]] forState:UIControlStateNormal];
        } else {
            [right setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        [right addTarget:self action:@selector(rightClick:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:right];
    } else if ([param objectForKey:@"rightImage"]) {
        
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 44.0)];
        
        UIButton *right = [UIButton buttonWithType:UIButtonTypeCustom];
        right.frame = rightView.frame;
        [right addTarget:self action:@selector(rightClick:) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *url = param[@"rightImage"];
        NSString *newURL;
        if ([url hasPrefix:@"//"]) {
            newURL = [NSString stringWithFormat:@"http:%@", url];
        } else if ([url hasPrefix:@"./"]) {
#ifdef DEVELOP_DEMO
            NSString *host = [[NSUserDefaults standardUserDefaults] stringForKey:@"host"];
            NSString *urlStr = [NSString stringWithFormat:@"http://%@/", host];
            newURL = [NSURL URLWithString:url relativeToURL:[NSURL URLWithString:urlStr]].absoluteString;
#else
            newURL = [NSString stringWithFormat:@"%@%@", SERVER, [url substringFromIndex:2]];
#endif
            
        } else if (![url hasPrefix:@"http"]) {
            // relative path
            newURL = [NSURL URLWithString:url relativeToURL:self.instance.scriptURL].absoluteString;
        }
        
        UIImageView *rightImage = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, (44.0-20.0)*0.5, 20.0, 20.0)];
        rightImage.contentMode = UIViewContentModeScaleAspectFit;
        [rightImage sd_setImageWithURL:[NSURL URLWithString:newURL]];
        
        [rightView addSubview:rightImage];
        [rightView addSubview:right];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)rightClick:(UIButton *)sender {
    if (self.titleCallback) {
        self.titleCallback(@{@"type": @"right"});
    }
}

#pragma mark - pick image

- (void)pickImageWithParam:(NSDictionary *)param callBack:(WXModuleCallback)callback {
    self.imageCallback = callback;
    
    BOOL allowEditing = NO;
    if (param && [param objectForKey:@"editable"]) {
        allowEditing = [param[@"editable"] boolValue];
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showImagePickerWithType:UIImagePickerControllerSourceTypePhotoLibrary allowEditing:allowEditing];
    }];
    [alertController addAction:photoAction];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self showImagePickerWithType:UIImagePickerControllerSourceTypeCamera allowEditing:allowEditing];
        }];
        [alertController addAction:cameraAction];
    }
    //取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消 " style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

- (void)showImagePickerWithType:(UIImagePickerControllerSourceType)type allowEditing:(BOOL)allowEditing {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = type;
    picker.delegate = self;
    picker.allowsEditing = allowEditing; //是否可编辑
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image;
    if ([info objectForKey:UIImagePickerControllerEditedImage]) {
        image = [info objectForKey:UIImagePickerControllerEditedImage];
    } else if ([info objectForKey:UIImagePickerControllerOriginalImage]) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    } else {
        [self showToastWithText:@"图片选取失败"];
        return;
    }
    __weak __typeof__ (self) wself = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [wself uploadImage:image];
    }];
}

- (void)uploadImage:(UIImage *)image {
//    Connection *connect = [[Connection alloc] init];
//    [connect uploadImageWithURL:@"http://app.bandou.cn/appbduser/upload" param:nil image:image callback:^(NSData *result, NSError *error) {
//        if (error) {
//            NSLog(@"upload image err: %@", error);
//            self.imageCallback(@{@"result": @(-1)});
//        } else {
//            NSError *jsonError;
//            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableContainers error:&jsonError];
//            if (!jsonError) {
//                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//                [dict setValue:@(0) forKey:@"result"];
//                if ([json objectForKey:@"file_id"]) {
//                    [dict setValue:json[@"file_id"] forKey:@"file_id"];
//                }
//                if ([json objectForKey:@"file_url"]) {
//                    [dict setValue:json[@"file_url"] forKey:@"file_url"];
//                }
//                self.imageCallback(dict);
//            } else {
//                NSLog(@"upload image result err: %@", jsonError);
//                self.imageCallback(@{@"result": @(-1)});
//            }
//        }
//    }];
}

#pragma mark - pick date

-(void)pickDateWithParam:(NSDictionary *)param callBack:(WXModuleCallback)callback {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                             message:@"请选择日期\n\n\n\n\n\n\n\n\n\n"
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(15, 30, 270, 200)];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [alertController.view addSubview:datePicker];
    if (param && [param objectForKey:@"date"]) {
        // TODO
        NSTimeInterval time = [param[@"date"] doubleValue];
        [datePicker setDate:[NSDate dateWithTimeIntervalSince1970:time/1000]];
    }
    
    //点击“确定”按钮后执行，handler代码块
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //获取选中的日期
        NSDate *selectedDate = datePicker.date;
        NSLog(@"date %@", selectedDate);
        NSTimeInterval time = selectedDate.timeIntervalSince1970;
        callback(@{@"date": @(time*1000)});
    }];
    //取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消 " style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];

    [alertController addAction:sureAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

#pragma mark - location

- (void)getLocationWithParam:(NSDictionary *)param callBack:(WXModuleCallback)callback {
    self.locationCallback = callback;
    if (param) {
        
    }
    [self getLocation];
}

- (void)getLocation {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusRestricted
        || status == kCLAuthorizationStatusDenied) {
        [self showToastWithText:@"请打开定位服务"];
        self.locationCallback(@{@"longitude": @(0.0), @"latitude": @(0.0)});
    } else {
        if (self.locationManager == nil) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        }
        if (status == kCLAuthorizationStatusAuthorizedAlways
            || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            [self.locationManager startUpdatingLocation];
        } else if (status == kCLAuthorizationStatusNotDetermined) {
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways
        || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [manager startUpdatingLocation];
    } else {
        [self showToastWithText:@"请打开定位服务"];
        self.locationCallback(@{@"longitude": @(0.0), @"latitude": @(0.0)});
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    if (locations) {
        CLLocation *location = locations.lastObject;
        [manager stopUpdatingLocation];
        CLLocationDegrees latitude = location.coordinate.latitude;
        CLLocationDegrees longitude = location.coordinate.longitude;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.locationCallback(@{@"longitude": @(longitude), @"latitude": @(latitude)});
        });
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"location error:%@", error);
    self.locationCallback(@{@"longitude": @(0.0), @"latitude": @(0.0)});
}

#pragma mark - pay
/*
- (void)payWithParam:(NSDictionary *)param callBack:(WXModuleCallback)callback {
    self.payCallback = callback;
    if (param && [param objectForKey:@"type"]) {
        NSString *type = param[@"type"];
        if ([type isEqualToString:@"ali"]) {
            [self aliPayWithString:param[@"param"]];
        } else if ([type isEqualToString:@"wexin"]) {
            [self weixinPayWithParam:param[@"param"]];
        }
    }
}

- (void)aliPayWithString:(NSString *)orderString {
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:ALI_PAY_SCHEME callback:^(NSDictionary *resultDic) {
        NSLog(@"result = %@",resultDic);
        
        BOOL result = NO;
        if (resultDic[@"resultStatus"]) {
            NSInteger status = [resultDic[@"resultStatus"] integerValue];
            if (status == 9000) {
                result = YES;
            } else {
                result = NO;
            }
        }
        NSString *memo = @"";
        if (resultDic[@"memo"]) {
            memo = resultDic[@"memo"];
        }
        NSDictionary *param = @{@"type": @"ali", @"success": @(result), @"msg": memo};
        self.payCallback(param);
    }];
}

- (void)aliPayNotification:(NSNotification *)notification {
    BOOL result = NO;
    NSString *memo = @"";
    if (notification.object) {
        NSDictionary *resultDic = notification.object;
        NSLog(@"result = %@",resultDic);
        
        if (resultDic[@"resultStatus"]) {
            NSInteger status = [resultDic[@"resultStatus"] integerValue];
            if (status == 9000) {
                result = YES;
            } else {
                result = NO;
            }
        }
        if (resultDic[@"memo"]) {
            memo = resultDic[@"memo"];
        }

    }
    NSDictionary *param = @{@"type": @"ali", @"success": @(result), @"msg": memo};
    self.payCallback(param);
}

- (void)weixinPayWithParam:(NSDictionary *)param {
    //调起微信支付
    PayReq *wxReq = [[PayReq alloc] init];
    wxReq.partnerId = param[@"partnerid"];
    wxReq.prepayId = param[@"prepayid"];
    wxReq.nonceStr = param[@"noncestr"];
    wxReq.timeStamp = 1467966402;
    if (param[@"timestamp"]) {
        wxReq.timeStamp = [param[@"timestamp"] intValue];
    }
    wxReq.package = param[@"_package"];
    wxReq.sign = param[@"sign"];
    [WXApi sendReq:wxReq];
}

- (void)weixinPayNotification:(NSNotification *)notification {
    BOOL result = NO;
    NSString *memo = @"";
    if (notification.object) {
        NSDictionary *resultDic = notification.object;
        if (resultDic[@"errCode"]) {
            NSInteger errCode = [resultDic[@"errCode"] integerValue];
            if (errCode == WXSuccess) {
                result = YES;
            } else {
                result = NO;
            }
        }
        if (resultDic[@"errStr"]) {
            memo = resultDic[@"errStr"];
        }
    }
    NSDictionary *param = @{@"type": @"weixin", @"success": @(result), @"msg": memo};
    self.payCallback(param);
}
*/
#pragma mark - callback

- (void)callBack:(WXModuleCallback)callback withParam:(id)param {
    dispatch_async(dispatch_get_main_queue(), ^{
        callback(param);
    });
}

#pragma mark - weex
- (void)updateInstanceState:(WXState)state
{
    if (_instance && _instance.state != state) {
        _instance.state = state;
        
        if (state == WeexInstanceAppear) {
            [[WXSDKManager bridgeMgr] fireEvent:_instance.instanceId ref:WX_SDK_ROOT_REF type:@"viewappear" params:nil domChanges:nil];
        }
        else if (state == WeexInstanceDisappear) {
            [[WXSDKManager bridgeMgr] fireEvent:_instance.instanceId ref:WX_SDK_ROOT_REF type:@"viewdisappear" params:nil domChanges:nil];
        }
    }
}

- (void)render {
    [self showLoading];
    [_instance destroyInstance];
    
    _instance = [[WXSDKInstance alloc] init];
    _instance.viewController = self;
    CGFloat width = self.view.frame.size.width;
    _instance.frame = CGRectMake(self.view.frame.size.width-width, 0, width, _weexHeight);
    
    NSString *randomURL = [NSString stringWithFormat:@"%@%@random=%d",self.url.absoluteString, self.url.query?@"&":@"?",arc4random()];
    [_instance renderWithURL:[NSURL URLWithString:randomURL] options:@{@"bundleUrl":[self.url absoluteString]} data:self.param];

//    [_instance renderWithURL:self.url options:@{@"bundleUrl":[self.url absoluteString]} data:self.param];
    
    __weak typeof(self) weakSelf = self;
    _instance.onCreate = ^(UIView *view) {
        if (weakSelf && weakSelf.weexView) {
            [weakSelf.weexView removeFromSuperview];
        }
        [weakSelf hideError];
        weakSelf.weexView = view;
        weakSelf.weexView.tag = WEEX_VIEW_TAG;
        weakSelf.weexView.alpha = 0.0;
        weakSelf.weexView.backgroundColor = [UIColor whiteColor];
        [weakSelf.view addSubview:weakSelf.weexView];
        [UIView animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
            weakSelf.weexView.alpha = 1.0;
        } completion:^(BOOL finished) {
            [weakSelf hideLoading];
        }];
    };
    
    _instance.onFailed = ^(NSError *error) {
        NSLog(@"weex failed:%@", error);
        [weakSelf hideLoading];
        [weakSelf showError];
    };
    
    _instance.renderFinish = ^ (UIView *view) {
        //process renderFinish
        [weakSelf updateInstanceState:WeexInstanceAppear];
    };
    
}

@end
