//
//  NSDictionary+BVJSONString.h
//  Library
//
//  Created by 陈颖鹏 on 14/11/13.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (BVJSONString)

- (NSString*)bv_jsonStringWithPrettyPrint:(BOOL)prettyPrint;

@end
