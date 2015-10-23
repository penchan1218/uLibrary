//
//  DBManager.h
//  Library
//
//  Created by 陈颖鹏 on 14-10-17.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetailedBookInfo.h"
#import "BookList.h"
#import "CachedBook.h"
#import "CachedSearchResults.h"
#import "BookCoverImage.h"

@class AppDelegate;

@interface DBManager : NSObject

@property (weak, nonatomic) AppDelegate *appDelegate;

+ (DBManager *)sharedManager;

//DetailedBookInfo

- (void)addObjectToDetailedBookInfo:(id)obj;

- (DetailedBookInfo *)checkIfObjectExistsInDetailedBookInfo:(NSString *)bookID;

- (void)removeObjectWithIdentifierFromDetailedBookInfo:(NSString *)identifier;

//BookList

- (void)createBookListNamed:(NSString *)name objects:(NSArray *)objects;

- (BookList *)checkIfBookListExist:(NSString *)identifier;

- (BOOL)checkIfObject:(NSString *)identifier ExistsInBookList:(BookList *)bookList;

- (void)addObjectToBookList:(id)obj;

- (void)removeObjectWithIdentifier:(NSString *)bookID fromBookList:(NSString *)name;

- (void)removeBookList:(NSString *)name;

//CachedSearchResults

- (void)cacheSearchResults:(NSDictionary *)searchInfo;

- (CachedSearchResults *)checkIfCachedSearchResultsExist:(NSString *)searchStr;

- (void)cleanCachedSearchResults;

//CachedBook

- (void)cacheBook:(NSDictionary *)bookInfo;

- (CachedBook *)checkIfCachedBookExists:(NSString *)bookID;

- (void)cleanCachedBooks;

//Common function

- (NSManagedObject *)queryForObjectWithIdentifier:(NSString *)identifier fromEntity:(NSString *)entityName;

- (NSArray *)takeOutRecordsInEntity:(NSString *)entityName;

- (NSError *)save;

@end
