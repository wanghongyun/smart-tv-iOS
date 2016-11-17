//
//  ViewController.m
//  bandou-weex
//
//  Created by BanDouMacmini-1 on 16/8/11.
//  Copyright © 2016年 WHY. All rights reserved.
//

#import "ViewController.h"
#import "WXViewController.h"
#import "SDImageCache.h"

#import "AppDelegate.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *input;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *host = [[NSUserDefaults standardUserDefaults] stringForKey:@"host"];
    if (!host || host.length == 0) {
        host = @"smarttv.webuildus.com/smart-tv-weex";
    }
    self.input.text = host;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)confirm:(UIButton *)sender {
    
    NSString *host = self.input.text;
    [[NSUserDefaults standardUserDefaults] setObject:host forKey:@"host"];

    NSString *urlStr = [NSString stringWithFormat:@"http://%@/dist/main.js", host];
    WXViewController *controller = [[WXViewController alloc] init];
    NSURL *url = [NSURL URLWithString:urlStr];
    controller.url = url;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clearCache:(UIButton *)sender {
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
}

- (IBAction)touch:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)editEnd:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)serverClick:(UIButton *)sender {
    self.input.text = @"smarttv.webuildus.com/smart-tv-weex";;
}

- (IBAction)localClick:(UIButton *)sender {
    self.input.text = nil;
}

@end
