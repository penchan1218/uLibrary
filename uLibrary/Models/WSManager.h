//
//  WSManager.h
//  uLibrary
//
//  Created by 陈颖鹏 on 14/12/21.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFRWebSocket.h"

@interface WSManager : NSObject <JFRWebSocketDelegate>

@property (strong, nonatomic) NSString *ip_address;
@property (strong, nonatomic) JFRWebSocket *webSocket;

@property (assign, readonly) BOOL loggedIn;
@property (assign, readonly) BOOL needsGetCurrent;
@property (assign, readonly) BOOL needsGetHistory;
@property (assign, readonly) BOOL shouldDisconnect;

@property (strong, nonatomic) void (^getCurrentCompletionHandler)(NSArray *currentArr);
@property (nonatomic, assign) NSUInteger page;
@property (strong, nonatomic) void (^getHistoryCompletionHandler)(NSUInteger max_page, NSUInteger curr_page, NSArray *historyArr);

@property (strong, nonatomic) NSMutableDictionary *renewBooksDic;

+ (WSManager *)sharedManager;

- (void)connect;

- (void)disconnect;

- (void)getCurrentWithCompletionHandler:(void (^)(NSArray *currentArr))completionHandler;

- (void)getHistoryOfPage:(NSUInteger)page withCompletionHandler:(void (^)(NSUInteger max_page, NSUInteger curr_page, NSArray *historyArr))completionHandler;

- (void)renewBook:(NSString *)renewID withCompletionHandler:(void (^)(BOOL success, NSString *msg))completionHandler;

@end
