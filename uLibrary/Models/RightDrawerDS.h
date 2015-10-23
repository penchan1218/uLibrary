//
//  RightDrawerDS.h
//  uLibrary
//
//  Created by 陈颖鹏 on 15/3/20.
//  Copyright (c) 2015年 UniqueStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RightDrawerDS : NSObject

@property (strong, atomic) NSDictionary *allIndexes;
@property (strong, atomic) NSMutableArray *indexArr;
@property (strong, atomic) NSArray *sortedIndexArr;
@property (strong, atomic) NSArray *rawDataSource;
@property (strong, atomic) NSMutableDictionary *filterDataSource;

+ (RightDrawerDS *)sharedInstance;

- (void)setUpDataSource;

- (void)addItemWithIdentifier:(NSString *)identifier;

- (void)removeItemWithIdentifier:(NSString *)identifier;

@end
