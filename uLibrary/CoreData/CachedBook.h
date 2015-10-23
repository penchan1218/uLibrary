//
//  CachedBook.h
//  uLibrary
//
//  Created by 陈颖鹏 on 14/12/5.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CachedBook : NSManagedObject

@property (nonatomic, retain) NSDate * expiredDate;
@property (nonatomic, retain) NSString * bookID;

@end
