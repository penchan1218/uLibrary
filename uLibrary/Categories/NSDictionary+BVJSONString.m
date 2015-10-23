//
//  NSDictionary+BVJSONString.m
//  Library
//
//  Created by 陈颖鹏 on 14/11/13.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "NSDictionary+BVJSONString.h"

@implementation NSDictionary (BVJSONString)

- (NSString*)bv_jsonStringWithPrettyPrint:(BOOL)prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

@end
