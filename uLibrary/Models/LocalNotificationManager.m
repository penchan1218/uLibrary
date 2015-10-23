//
//  LocalNotificationManager.m
//  uLibrary
//
//  Created by 陈颖鹏 on 15/3/27.
//  Copyright (c) 2015年 UniqueStudio. All rights reserved.
//

#import "LocalNotificationManager.h"

@implementation LocalNotificationManager

+ (LocalNotificationManager *)sharedInstance {
    static LocalNotificationManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LocalNotificationManager alloc] init];
    });
    return sharedInstance;
}

// 添加推送的位置
//     登录或刷新成功后
//         - DidBorrowView.m

- (void)addLocalNotificationOnDate:(NSDate *)date level:(NSInteger)level {
    NSArray *localNotifs = [[UIApplication sharedApplication] scheduledLocalNotifications];
    BOOL exist = NO;
    for (UILocalNotification *localNotif in localNotifs) {
        if ([date timeIntervalSinceDate:localNotif.fireDate] == 0) {
            exist = YES;
            NSInteger oldLevel = [[localNotif.userInfo objectForKey:@"level"] integerValue];
            if (oldLevel > level) {
                [[UIApplication sharedApplication] cancelLocalNotification:localNotif];
                
                [self addLocalNotificationWithMsg:[self msgWithLevel:level]
                                         pushDate:date
                                         userInfo:@{@"level": @(level)}
                                           repeat:NO];
            }
            break;
        }
    }
    
    if (exist == NO) {
        [self addLocalNotificationWithMsg:[self msgWithLevel:level]
                                 pushDate:date
                                 userInfo:@{@"level": @(level)}
                                   repeat:NO];
    }
    
}

- (NSString *)msgWithLevel:(NSInteger)level {
    switch (level) {
        case 1:
            return @"有书不还，倾家荡产(๑ó﹏ò๑)";
        case 2:
            return @"你有书明天到期了！";
        case 3:
            return @"咦，你是不是有书要还？";
        default:
            return nil;
    }
}

- (void)addLocalNotificationWithMsg:(NSString *)msg pushDate:(NSDate *)date userInfo:(NSDictionary *)userInfo repeat:(BOOL)repeat {
    UILocalNotification * notification = [[UILocalNotification alloc] init];
    NSDate * pushDate = date;
    if (notification!=nil) {
        //设置 推送时间
        notification.fireDate= pushDate;
        //设置 时区
        notification.timeZone = [NSTimeZone defaultTimeZone];
        if (repeat) {
            //设置 重复间隔
            notification.repeatInterval = kCFCalendarUnitDay;
        }
        //设置 推送声音
        notification.soundName = UILocalNotificationDefaultSoundName;
        //设置 推送提示语
        notification.alertBody = msg;
        //设置 icon 上 红色数字
        notification.applicationIconBadgeNumber = 1;
        //取消 推送 用的 字典  便于识别
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:userInfo];
        [dic setObject:[self msgWithLevel:[userInfo[@"level"] integerValue]] forKey:@"msg"];
        notification.userInfo = [NSDictionary dictionaryWithDictionary:dic];
        //添加推送到 Application
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    NSLog(@"以添加本地推送: %@", msg);
}

// 取消推送的位置
//     打开App的时候
//         － AppDelegate.m
//     刷新时
//         － DidBorrowView.m
//     登出时
//         - DidBorrowView.m

- (void)removeAllLocalNotifications {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

@end
