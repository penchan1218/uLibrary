//
//  LocalNotificationManager.h
//  uLibrary
//
//  Created by 陈颖鹏 on 15/3/27.
//  Copyright (c) 2015年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface LocalNotificationManager : NSObject

+ (LocalNotificationManager *)sharedInstance;

- (void)addLocalNotificationWithMsg:(NSString *)msg pushDate:(NSDate *)date userInfo:(NSDictionary *)userInfo repeat:(BOOL)repeat;

- (void)addLocalNotificationOnDate:(NSDate *)date level:(NSInteger)level;

- (void)removeAllLocalNotifications;

@end
