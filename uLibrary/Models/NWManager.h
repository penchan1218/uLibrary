//
//  NWManager.h
//  Library
//
//  Created by 陈颖鹏 on 14/11/8.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "SimplePingHelper.h"
#import <netdb.h>
#import <sys/socket.h>
#import <arpa/inet.h>

@interface NWManager : NSObject

@property (nonatomic, assign) BOOL isPingCompleted;

@property (strong, nonatomic) NSString *ipAddress;

@property (strong, nonatomic) NSString *searchString;

@property (nonatomic, assign) NSInteger page;

@property (strong, nonatomic) void (^getSearchResultsBlock)(NSInteger status, NSDictionary *jsonDic);

@property (strong, nonatomic) NSString *identifier;

@property (strong, nonatomic) void (^getDetailedBookInfoBlock)(NSInteger status, NSDictionary *jsonDic);

@property (nonatomic, assign) NSInteger tag;

@property (strong, nonatomic) void (^getHomePageBookListsBlock)(NSInteger status, NSDictionary* info);

- (void)getHomePageBookListWithTag:(NSInteger)tag withCompletionHandler:(void (^)(NSInteger status, NSDictionary* info))completionHandler;

- (void)getBookImage:(NSString *)urlStr withCompletionHandler:(void (^)(NSInteger status, UIImage *image))completionHandler;

- (void)getSearchResults:(NSString *)searchString searchPage:(NSUInteger)page withCompletionHandler:(void (^)(NSInteger status, NSDictionary *jsonDic))completionHandler;

- (void)getDetailedBookInfo:(NSString *)identifier withCompletionHandler:(void (^)(NSInteger status, NSDictionary *jsonDic))completionHandler;

@end
