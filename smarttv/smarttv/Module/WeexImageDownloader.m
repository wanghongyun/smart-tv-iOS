//
//  WeexImageDownloader.m
//  TestWeex
//
//  Created by BanDouMacmini-1 on 16/7/28.
//  Copyright © 2016年 BanDouMacmini-1. All rights reserved.
//

#import "WeexImageDownloader.h"
#import "SDWebImageManager.h"
#import "Constants.h"

@implementation WeexImageDownloader

@synthesize weexInstance;

- (id<WXImageOperationProtocol>)downloadImageWithURL:(NSString *)url
                                          imageFrame:(CGRect)imageFrame
                                            userInfo:(NSDictionary *)options
                                           completed:(void(^)(UIImage *image,  NSError *error, BOOL finished))completedBlock {
    NSString *newURL = url;
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
        newURL = [NSURL URLWithString:url relativeToURL:weexInstance.scriptURL].absoluteString;
    }
    
    return (id<WXImageOperationProtocol>)[[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:newURL] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (completedBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completedBlock(image, error, finished);
            });
        }
    }];
}

@end
