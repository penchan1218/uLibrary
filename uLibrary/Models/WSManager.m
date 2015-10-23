//
//  WSManager.m
//  uLibrary
//
//  Created by 陈颖鹏 on 14/12/21.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "WSManager.h"
#import "NSDictionary+BVJSONString.h"

@implementation WSManager

+ (WSManager *)sharedManager {
    static WSManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WSManager alloc] init];
        sharedInstance.renewBooksDic = [NSMutableDictionary dictionary];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _ip_address = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ip_address"] stringByAppendingString:@"/profile"];
        _loggedIn = NO;
        _needsGetCurrent = NO;
        _needsGetHistory = NO;
        _shouldDisconnect = NO;
    }
    return self;
}

- (void)connect {
    if (self.webSocket.isConnected == NO) {
        [self.webSocket connect];
    }
}

- (void)disconnect {
    _shouldDisconnect = YES;
    if (self.webSocket.isConnected == YES) {
        [self.webSocket disconnect];
    }
}

- (void)login {
    NSString *user_name = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_name"];
    NSString *user_code = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_code"];
    if (user_name != nil && user_name.length != 0 &&
        user_code != nil && user_code.length != 0) {
        NSDictionary *loginDic = @{@"action": @"login",
                                   @"lib_code": @(0),
                                   @"token": @"login",
                                   @"username": user_name,
                                   @"password": user_code};
        [self.webSocket writeString:[loginDic bv_jsonStringWithPrettyPrint:NO]];
    } else {
        NSLog(@"Warning---->>>>websocket login no name or password");
        [self disconnect];
    }
}

- (void)getCurrentWithCompletionHandler:(void (^)(NSArray *currentArr))completionHandler {
    _getCurrentCompletionHandler = completionHandler;
    if (_loggedIn == NO) {
        _needsGetCurrent = YES;
        _shouldDisconnect = NO;
        [self connect];
    } else {
        NSDictionary *getCurrentDic = @{@"action": @"current",
                                        @"lib_code": @(0),
                                        @"page": @(1),
                                        @"token": @"current"};
        [self.webSocket writeString:[getCurrentDic bv_jsonStringWithPrettyPrint:NO]];
    }
}

- (void)getHistoryOfPage:(NSUInteger)page withCompletionHandler:(void (^)(NSUInteger max_page, NSUInteger curr_page, NSArray *historyArr))completionHandler {
    _page = page;
    _getHistoryCompletionHandler = completionHandler;
    if (_loggedIn == NO) {
        _needsGetHistory = YES;
        _shouldDisconnect = NO;
        [self connect];
    } else {
        NSDictionary *getHistoryDic = @{@"action": @"history",
                                        @"lib_code": @(0),
                                        @"token": @"history",
                                        @"page": @(page)};
        [self.webSocket writeString:[getHistoryDic bv_jsonStringWithPrettyPrint:NO]];
    }
}

- (void)renewBook:(NSString *)renewID withCompletionHandler:(void (^)(BOOL success, NSString *msg))completionHandler {
    NSLog(@"要续借:%@", renewID);
    [_renewBooksDic setObject:completionHandler forKey:renewID];
    if (_loggedIn == NO) {
        _shouldDisconnect = NO;
        [self connect];
    } else {
        NSDictionary *renewBookDic = @{@"action": @"renew",
                                       @"renew_list": @[renewID],
                                       @"lib_code": @(0),
                                       @"token": @"renew"};
        [self.webSocket writeString:[renewBookDic bv_jsonStringWithPrettyPrint:NO]];
    }
}

- (void)websocketDidConnect:(JFRWebSocket *)socket {
    NSLog(@"websocket---->>>>connect");
    [self login];
}

- (void)websocket:(JFRWebSocket *)socket didReceiveMessage:(NSString *)string {
    NSLog(@"websocket---->>>>receive message\n%@", string);
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    if (responseDic != nil) {
        NSString *token = responseDic[@"token"];
        if (token != nil) {
            if ([token isEqualToString:@"login"]) {
                if ([responseDic[@"msg"] isEqualToString:@"login success"]) {
                    NSLog(@"websocket---->>>>login success");
                    //让登录框接受登录成功的消息
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"WaitingForLoggingIn"
                                                                        object:nil
                                                                      userInfo:@{@"status": @"success"}];
                    _loggedIn = YES;
                    if (_needsGetCurrent == YES) {
                        [_renewBooksDic removeAllObjects];
                        [self getCurrentWithCompletionHandler:_getCurrentCompletionHandler];
                    }
                    if (_needsGetHistory == YES) {
                        [self getHistoryOfPage:_page withCompletionHandler:_getHistoryCompletionHandler];
                    }
                    if (_renewBooksDic.count > 0) {
                        NSArray *allKeys = [_renewBooksDic allKeys];
                        for (NSString *key in allKeys) {
                            [self renewBook:key withCompletionHandler:_renewBooksDic[key]];
                        }
                    }
                } else if ([responseDic[@"msg"] isEqualToString:@"login failed"]) {
                    NSLog(@"websocket---->>>>login failed");
                    //让登录框接受登录失败的消息
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"WaitingForLoggingIn"
                                                                        object:nil
                                                                      userInfo:@{@"status": @"fail"}];
                    //清除已储藏好的账号和密码信息
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_name"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_code"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [self disconnect];
                }
            } else if ([token isEqualToString:@"current"]) {
                if (_getCurrentCompletionHandler != nil) {
                    _getCurrentCompletionHandler(responseDic[@"objects"]);
                    _getCurrentCompletionHandler = nil;
                } else {
                    NSLog(@"Warning---->>>>websocket no get current block");
                }
                _needsGetCurrent = NO;
            } else if ([token isEqualToString:@"history"]) {
                if (_getHistoryCompletionHandler != nil) {
                    _getHistoryCompletionHandler([responseDic[@"max_page"] integerValue], _page,  responseDic[@"objects"]);
                    _getHistoryCompletionHandler = nil;
                } else {
                    NSLog(@"Warning---->>>>websocket no get history block");
                }
                _needsGetHistory = NO;
            } else if ([token isEqualToString:@"renew"]) {
                NSString *msg = responseDic[@"objects"][0][@"msg"];
                NSString *key = responseDic[@"objects"][0][@"renew_id"];
                
                NSLog(@"ID:%@\nMessage:%@", key, msg);
                
                void (^tmpBlock)(BOOL success, NSString *msg) = _renewBooksDic[key];
                
                if ([msg rangeOfString:@"已续借"].location != NSNotFound) {
                    tmpBlock(YES, msg);
                } else {
                    tmpBlock(NO, msg);
                }
                
                [_renewBooksDic removeObjectForKey:key];
                
                NSLog(@"responseDic:%@", responseDic);
            }
        } else {
            NSLog(@"Warning---->>>>websocket no token message received");
        }
    } else {
        NSLog(@"Warning!---->>>>websocket parse no dictionary");
    }
}

- (void)websocketDidDisconnect:(JFRWebSocket *)socket error:(NSError *)error {
    NSLog(@"websocket---->>>>disconnect with error: %@", error);
    _loggedIn = NO;
    if (_shouldDisconnect == YES) {
        _needsGetCurrent = NO;
        _needsGetHistory = NO;
        _getCurrentCompletionHandler = nil;
        _getHistoryCompletionHandler = nil;
        _shouldDisconnect = NO;
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self connect];
        });
    }
}

- (JFRWebSocket *)webSocket {
    if (_webSocket == nil) {
        _webSocket = [[JFRWebSocket alloc] initWithURL:[NSURL URLWithString:_ip_address] protocols:nil];
        _webSocket.delegate = self;
    }
    return _webSocket;
}

@end
