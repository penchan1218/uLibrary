//
//  DetailedBookInfo.h
//  uLibrary
//
//  Created by 陈颖鹏 on 14/12/5.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DetailedBookInfo : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * referenceCount;
@property (nonatomic, retain) NSString * query_id;
@property (nonatomic, retain) NSString * publish;
@property (nonatomic, retain) NSString * order_status;
@property (nonatomic, retain) NSData * lib_info;
@property (nonatomic, retain) NSString * isbn;
@property (nonatomic, retain) NSString * detail;
@property (nonatomic, retain) NSString * cover_image_url;
@property (nonatomic, retain) NSString * bookID;
@property (nonatomic, retain) NSString * author;

@end
