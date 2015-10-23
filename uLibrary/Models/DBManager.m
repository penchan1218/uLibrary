//
//  DBManager.m
//  Library
//
//  Created by 陈颖鹏 on 14-10-17.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "DBManager.h"
#import "AppDelegate.h"
#import "RightDrawerDS.h"

@implementation DBManager

+ (DBManager *)sharedManager {
    static DBManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DBManager alloc] init];
    });
    return manager;
}

#pragma mark - DetailedBookInfo

- (void)addObjectToDetailedBookInfo:(id)obj {
    NSDictionary *dataSource = obj;
    
    DetailedBookInfo *detailedBookInfo = [self checkIfObjectExistsInDetailedBookInfo:dataSource[@"id"]];
    
    if (detailedBookInfo == nil) {
        DetailedBookInfo *newObj = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([DetailedBookInfo class])
                                                                 inManagedObjectContext:self.appDelegate.managedObjectContext];
        newObj.author = dataSource[@"author"];
        newObj.cover_image_url = dataSource[@"cover_image_url"];
        newObj.detail = dataSource[@"detail"];
        newObj.bookID = dataSource[@"id"];
        newObj.isbn = dataSource[@"isbn"];
        newObj.lib_info = [NSKeyedArchiver archivedDataWithRootObject:dataSource[@"lib_info"]];
        newObj.order_status = dataSource[@"order_status"];
        newObj.publish = dataSource[@"publish"];
        newObj.query_id = dataSource[@"query_id"];
        newObj.title = dataSource[@"title"];
        newObj.referenceCount = @(1);
    } else {
        detailedBookInfo.referenceCount = @(detailedBookInfo.referenceCount.integerValue+1);
    }
    
    NSLog(@"Add detailed book info error: %@", [self save]);
}

- (DetailedBookInfo *)checkIfObjectExistsInDetailedBookInfo:(NSString *)bookID {
    return (DetailedBookInfo *)[self queryForObjectWithIdentifier:bookID fromEntity:NSStringFromClass([DetailedBookInfo class])];
}

- (void)removeObjectWithIdentifierFromDetailedBookInfo:(NSString *)identifier {
    DetailedBookInfo *detailedBookInfo = [self checkIfObjectExistsInDetailedBookInfo:identifier];
    
    if (detailedBookInfo == nil) {
        NSLog(@"Delete detailed book info but the book doesn't exist");
        return ;
    } else {
        if ([detailedBookInfo.referenceCount integerValue] <=1) {
            [self.appDelegate.managedObjectContext deleteObject:detailedBookInfo];
        } else {
            detailedBookInfo.referenceCount = @(detailedBookInfo.referenceCount.integerValue-1);
        }
    }
    
    NSLog(@"Delete detailed book info error: %@", [self save]);
}

#pragma mark - BookList

- (void)createBookListNamed:(NSString *)name objects:(NSArray *)objects {
    BookList *newObj = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([BookList class])
                                                     inManagedObjectContext:self.appDelegate.managedObjectContext];
    newObj.name = name;
    newObj.bookList = [NSKeyedArchiver archivedDataWithRootObject:objects == nil? [NSMutableArray array]: objects];
    
    NSLog(@"Create book list error: %@", [self save]);
}

- (BookList *)checkIfBookListExist:(NSString *)identifier {
    return (BookList *)[self queryForObjectWithIdentifier:identifier fromEntity:NSStringFromClass([BookList class])];
}

- (BOOL)checkIfObject:(NSString *)identifier ExistsInBookList:(BookList *)bookList {
    NSMutableArray *mutArr = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:bookList.bookList]];
    for (NSInteger i = 0; i < mutArr.count; i++) {
        if ([mutArr[i] isEqualToString:identifier]) {
            return YES;
        }
    }
    return NO;
}

- (void)addObjectToBookList:(id)obj {
    NSDictionary *dataSource = obj;
    NSString *name = dataSource[@"name"];
    
    BookList *bookList = [self checkIfBookListExist:name];
    
    if (bookList == nil) {
        [self createBookListNamed:name objects:@[dataSource[@"id"]]];
        [self addObjectToDetailedBookInfo:obj];
    } else {
        if ([self checkIfObject:dataSource[@"id"] ExistsInBookList:bookList] == NO) {
            NSMutableArray *mutArr = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:bookList.bookList]];
            [mutArr addObject:dataSource[@"id"]];
            bookList.bookList = [NSKeyedArchiver archivedDataWithRootObject:mutArr];
            [self addObjectToDetailedBookInfo:obj];
        }
    }
    
    if ([name isEqualToString:@"DefaultBookList"]) {
        [[RightDrawerDS sharedInstance] addItemWithIdentifier:dataSource[@"id"]];
    }
    
    NSLog(@"Add object to booklist error: %@", [self save]);
}

- (void)removeObjectWithIdentifier:(NSString *)bookID fromBookList:(NSString *)name {
    BookList *bookList = [self checkIfBookListExist:name];
    
    if (bookList != nil) {
        if (bookID != nil && bookID.length > 0) {
            NSMutableArray *mutArr = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:bookList.bookList]];
            for (NSInteger i = 0; i < [mutArr count]; i++) {
                if ([mutArr[i] isEqualToString:bookID]) {
                    [mutArr removeObjectAtIndex:i];
                    [self removeObjectWithIdentifierFromDetailedBookInfo:bookID];
                    break;
                }
            }
            bookList.bookList = [NSKeyedArchiver archivedDataWithRootObject:mutArr];
            NSLog(@"Delete book list error: %@", [self save]);
        }
    }
    
    if ([name isEqualToString:@"DefaultBookList"]) {
        [[RightDrawerDS sharedInstance] removeItemWithIdentifier:bookID];
    }
}

- (void)removeBookList:(NSString *)name {
    BookList *bookList = [self checkIfBookListExist:name];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:bookList.bookList];
    for (NSInteger i = 0; i < array.count; i++) {
        [self removeObjectWithIdentifier:array[i] fromBookList:name];
    }
    
    [self.appDelegate.managedObjectContext deleteObject:bookList];
}

#pragma mark - CachedSearchResults

- (void)cacheSearchResults:(NSDictionary *)searchInfo {
    NSString *name = searchInfo[@"name"];
    NSArray *searchResults = searchInfo[@"searchResults"];
    
    CachedSearchResults *cachedSearchResults = [self checkIfCachedSearchResultsExist:name];
    if (cachedSearchResults != nil) {
        [self.appDelegate.managedObjectContext deleteObject:cachedSearchResults];
    }
    
    CachedSearchResults *newObj = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([CachedSearchResults class])
                                                                inManagedObjectContext:self.appDelegate.managedObjectContext];
    newObj.name = name;
    newObj.searchResults = [NSKeyedArchiver archivedDataWithRootObject:searchResults];
    newObj.expiredDate = [NSDate date];
    
    NSLog(@"Cache search results error: %@", [self save]);
}

- (CachedSearchResults *)checkIfCachedSearchResultsExist:(NSString *)searchStr {
    return (CachedSearchResults *)[self queryForObjectWithIdentifier:searchStr fromEntity:NSStringFromClass([CachedSearchResults class])];
}

- (void)cleanCachedSearchResults {
    NSArray *fetchResults = [self takeOutRecordsInEntity:NSStringFromClass([CachedSearchResults class])];
    for (NSInteger i = 0; i < fetchResults.count; i++) {
        CachedSearchResults *tempCachedSearchResults = fetchResults[i];
        if ([[[NSDate alloc] initWithTimeInterval:60*60*24*2 sinceDate:tempCachedSearchResults.expiredDate] compare:[NSDate date]] == NSOrderedAscending) {
            NSLog(@"%@", tempCachedSearchResults.name);
            [self.appDelegate.managedObjectContext deleteObject:tempCachedSearchResults];
        }
    }
    NSLog(@"Clean cached search results error: %@", [self save]);
}

#pragma mark - CachedBook

- (void)cacheBook:(NSDictionary *)bookInfo {
    NSString *bookID = bookInfo[@"id"];
    CachedBook *cachedBook = [self checkIfCachedBookExists:bookID];
    if (cachedBook != nil) {
        [self removeObjectWithIdentifierFromDetailedBookInfo:bookID];
        [self.appDelegate.managedObjectContext deleteObject:cachedBook];
    }
    
    CachedBook *newObj = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([CachedBook class])
                                                       inManagedObjectContext:self.appDelegate.managedObjectContext];
    newObj.bookID = bookID;
    newObj.expiredDate = [NSDate date];
    [self addObjectToDetailedBookInfo:bookInfo];
    
    NSLog(@"Cache book error: %@", [self save]);
}

- (CachedBook *)checkIfCachedBookExists:(NSString *)bookID {
    return (CachedBook *)[self queryForObjectWithIdentifier:bookID fromEntity:NSStringFromClass([CachedBook class])];
}

- (void)cleanCachedBooks {
    NSArray *fetchResults = [self takeOutRecordsInEntity:NSStringFromClass([CachedBook class])];
    for (NSInteger i = 0; i < fetchResults.count; i++) {
        CachedBook *tempCachedBook = fetchResults[i];
        if ([[[NSDate alloc] initWithTimeInterval:60*60*24*2 sinceDate:tempCachedBook.expiredDate] compare:[NSDate date]] == NSOrderedAscending) {
            [self removeObjectWithIdentifierFromDetailedBookInfo:tempCachedBook.bookID];
            [self.appDelegate.managedObjectContext deleteObject:tempCachedBook];
        }
    }
    NSLog(@"Clean cached books error: %@", [self save]);
}

#pragma mark - Common function

- (NSManagedObject *)queryForObjectWithIdentifier:(NSString *)identifier fromEntity:(NSString *)entityName {
    NSArray *fetchResults = [self takeOutRecordsInEntity:entityName];
    if ([entityName isEqualToString:NSStringFromClass([DetailedBookInfo class])]) {
        for (NSInteger i = 0; i < [fetchResults count]; i++) {
            DetailedBookInfo *entity = fetchResults[i];
            if ([entity.bookID isEqualToString:identifier]) {
                return entity;
            }
        }
    } else if ([entityName isEqualToString:NSStringFromClass([BookList class])]) {
        for (NSInteger i = 0; i < fetchResults.count; i++) {
            BookList *entity = fetchResults[i];
            if ([entity.name isEqualToString:identifier]) {
                return entity;
            }
        }
    } else if ([entityName isEqualToString:NSStringFromClass([BookCoverImage class])]) {
        for (NSInteger i = 0; i < [fetchResults count]; i++) {
            BookCoverImage *entity = fetchResults[i];
            if ([entity.cover_image_url isEqualToString:identifier]) {
                return entity;
            }
        }
    } else if ([entityName isEqualToString:NSStringFromClass([CachedSearchResults class])]) {
        for (NSInteger i = 0; i < fetchResults.count; i++) {
            CachedSearchResults *entity = fetchResults[i];
            if ([entity.name isEqualToString:identifier]) {
                return entity;
            }
        }
    } else if ([entityName isEqualToString:NSStringFromClass([CachedBook class])]) {
        for (NSInteger i = 0; i < fetchResults.count; i++) {
            CachedBook *entity = fetchResults[i];
            if ([entity.bookID isEqualToString:identifier]) {
                return entity;
            }
        }
    }
    return nil;
}

- (NSArray *)takeOutRecordsInEntity:(NSString *)entityName {
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName
                                                         inManagedObjectContext:self.appDelegate.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    return [self.appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:nil];
}

- (NSError *)save {
    NSError *error;
    [self.appDelegate.managedObjectContext save:&error];
    return error;
}

- (AppDelegate *)appDelegate {
    if (_appDelegate == nil) {
        _appDelegate = [[UIApplication sharedApplication] delegate];
    }
    return _appDelegate;
}

@end
