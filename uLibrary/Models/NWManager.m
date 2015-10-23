//
//  NWManager.m
//  Library
//
//  Created by 陈颖鹏 on 14/11/8.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "NWManager.h"

@implementation NWManager

- (id)init {
    self = [super init];
    if (self) {
        _isPingCompleted = NO;
        _ipAddress = [[NSUserDefaults standardUserDefaults] objectForKey:@"ip_address"];
    }
    return self;
}

- (void)checkIfNetworkConnected {
    [SimplePingHelper ping:@"baidu.com" target:self sel:@selector(pingResult:)];
}

- (void)pingResult:(NSNumber *)success {
    if ([success boolValue] == YES) {
        self.isPingCompleted = YES;
    } else {
        self.isPingCompleted = NO;
    }
}

-(NSString*)getIPWithHostName:(const NSString*)hostName
{
    const char *hostN= [hostName UTF8String];
    struct hostent* phot;
    
    @try {
        phot = gethostbyname(hostN);
        
    }
    @catch (NSException *exception) {
        return nil;
    }
    
    struct in_addr ip_addr;
    memcpy(&ip_addr, phot->h_addr_list[0], 4);
    char ip[20] = {0};
    inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));
    
    NSString* strIPAddress = [NSString stringWithUTF8String:ip];
    return strIPAddress;
}

- (void)getBookImage:(NSString *)urlStr withCompletionHandler:(void (^)(NSInteger status, UIImage *image))completionHandler {
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString:urlStr
                                                                                parameters:nil error:nil];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFHTTPResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionHandler(1, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([error.localizedDescription isEqualToString:@"The Internet connection appears to be offline."]) {
            completionHandler(-1, nil);
        } else {
            completionHandler(0, nil);
        }
    }];
    [op start];
}

- (void)getHomePageBookListWithTag:(NSInteger)tag withCompletionHandler:(void (^)(NSInteger status, NSDictionary* info))completionHandler {
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString:[NSString stringWithFormat:@"%@/static/temp/bookrec0%ld.json", self.ipAddress, (unsigned long)(tag+1)]
                                                                                parameters:nil error:nil];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionHandler(1, responseObject);
        
        if (_isPingCompleted == YES) {
            _getHomePageBookListsBlock = nil;
            [[NSUserDefaults standardUserDefaults] setObject:_ipAddress forKey:@"ip_address"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if ([error.localizedDescription isEqualToString:@"The Internet connection appears to be offline."] ||
            [error.localizedDescription isEqualToString:@"未能连接到服务器。"]) {
            completionHandler(-1, nil);
        } else {
            if (_isPingCompleted == NO) {
                _tag = tag;
                _getHomePageBookListsBlock = completionHandler;
                
                _ipAddress = nil;
                
                [self checkIfNetworkConnected];
            } else {
                completionHandler(0, nil);
            }
        }
        if (_isPingCompleted == YES) {
            _getHomePageBookListsBlock = nil;
        }
    }];
    [op start];
    
    
}

- (void)getSearchResults:(NSString *)searchString searchPage:(NSUInteger)page withCompletionHandler:(void (^)(NSInteger status, NSDictionary *jsonDic))completionHandler {
    NSDictionary *param = @{@"key": searchString,
                            @"curr_page": @(page),
                            @"se_type": @"key",
                            @"lib_code": @(0)};
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST"
                                                                                 URLString:[NSString stringWithFormat:@"%@/search", self.ipAddress]
                                                                                parameters:param error:nil];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionHandler(1, responseObject);
        if (_isPingCompleted == YES) {
            _searchString = nil;
            _getSearchResultsBlock = nil;
            
            [[NSUserDefaults standardUserDefaults] setObject:_ipAddress forKey:@"ip_address"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([error.localizedDescription isEqualToString:@"The Internet connection appears to be offline."] ||
            [error.localizedDescription isEqualToString:@"未能连接到服务器。"]) {
            completionHandler(-1, nil);
        } else {
            if (_isPingCompleted == NO) {
                _searchString = searchString;
                _page = page;
                _getSearchResultsBlock = completionHandler;
                
                _ipAddress = nil;
                
                [self checkIfNetworkConnected];
            } else {
                completionHandler(0, nil);
            }
        }
        if (_isPingCompleted == YES) {
            _searchString = nil;
            _getSearchResultsBlock = nil;
        }
    }];
    [op start];
}

- (void)getDetailedBookInfo:(NSString *)identifier withCompletionHandler:(void (^)(NSInteger status, NSDictionary *jsonDic))completionHandler {
    NSDictionary *param = @{@"id": identifier,
                            @"id_type": @"record",
                            @"lib_code": @"0"};
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST"
                                                                                 URLString:[NSString stringWithFormat:@"%@/detail", self.ipAddress]
                                                                                parameters:param error:nil];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionHandler(1, responseObject);
        
        if (_isPingCompleted == YES) {
            _identifier = nil;
            _getDetailedBookInfoBlock = nil;
            
            [[NSUserDefaults standardUserDefaults] setObject:_ipAddress forKey:@"ip_address"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([error.localizedDescription isEqualToString:@"The Internet connection appears to be offline."] ||
            [error.localizedDescription isEqualToString:@"未能连接到服务器。"]) {
            completionHandler(-1, nil);
        } else {
            if (_isPingCompleted == NO) {
                _identifier = identifier;
                _getDetailedBookInfoBlock = completionHandler;
                
                _ipAddress = nil;
                
                [self checkIfNetworkConnected];
            } else {
                completionHandler(0, nil);
            }
        }
        if (_isPingCompleted == YES) {
            _identifier = nil;
            _getDetailedBookInfoBlock = nil;
        }
    }];
    [op start];
}

- (NSString *)ipAddress {
    if (_ipAddress == nil) {
        _ipAddress = [NSString stringWithFormat:@"http://%@:2333", [self getIPWithHostName:@"ybook.me"]];
    }
    return _ipAddress;
}

- (void)setIsPingCompleted:(BOOL)isPingCompleted {
    _isPingCompleted = isPingCompleted;
    if (isPingCompleted == YES) {
        if (_searchString != nil) {
            [self getSearchResults:_searchString searchPage:_page withCompletionHandler:_getSearchResultsBlock];
        } else if (_identifier != nil) {
            [self getDetailedBookInfo:_identifier withCompletionHandler:_getDetailedBookInfoBlock];
        } else if (_getHomePageBookListsBlock != nil) {
            [self getHomePageBookListWithTag:_tag withCompletionHandler:_getHomePageBookListsBlock];
        }
    } else {
        if (_searchString != nil) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _getSearchResultsBlock(-1, nil);
                _searchString = nil;
                _getSearchResultsBlock = nil;
            });
        } else if (_identifier != nil) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _getDetailedBookInfoBlock(-1,nil);
                _identifier = nil;
                _getDetailedBookInfoBlock = nil;
            });
        } else if (_getHomePageBookListsBlock != nil) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _getHomePageBookListsBlock(-1, nil);
                _getHomePageBookListsBlock = nil;
            });
        }
    }
}

@end
