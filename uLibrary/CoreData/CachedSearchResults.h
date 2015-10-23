//
//  CachedSearchResults.h
//  uLibrary
//
//  Created by 陈颖鹏 on 14/12/5.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CachedSearchResults : NSManagedObject

@property (nonatomic, retain) NSData * searchResults;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * expiredDate;

@end
