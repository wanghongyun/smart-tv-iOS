//
//  AppDelegate.h
//  smarttv
//
//  Created by BanDouMacmini-1 on 2016/10/31.
//  Copyright © 2016年 WHY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;

-(void)gotoMainWithIndex:(NSInteger)index;
- (void)gotoMainWithServer:(NSString *)server;

@end

