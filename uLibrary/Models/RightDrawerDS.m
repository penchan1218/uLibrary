//
//  RightDrawerDS.m
//  uLibrary
//
//  Created by 陈颖鹏 on 15/3/20.
//  Copyright (c) 2015年 UniqueStudio. All rights reserved.
//

#import "RightDrawerDS.h"
#import "DBManager.h"

@implementation RightDrawerDS

+ (RightDrawerDS *)sharedInstance {
    static RightDrawerDS *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RightDrawerDS alloc] init];
    });
    return sharedInstance;
}

- (void)setUpDataSource {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        _allIndexes = [NSDictionary dictionaryWithObjectsAndKeys:@"马列主义毛泽东思想", @"A", @"哲学", @"B", @"社会科学总论", @"C", @"政治法律", @"D", @"军事", @"E", @"经济", @"F", @"文化科学教育体育", @"G", @"语言、文字", @"H", @"文学", @"I", @"艺术", @"J", @"历史地理", @"K", @"自然科学总论", @"N", @"数理科学和化学", @"O", @"天文学、地球科学", @"P", @"生物科学", @"Q", @"医药卫生", @"R", @"农业科学", @"S", @"工业技术", @"T", @" 一般工业技术", @"TB", @"矿业工程", @"TD", @"石油、天然气工业", @"TE", @"冶金工业", @"TF", @"金属学与金属工艺", @"TG", @"机械、仪表工业", @"TH", @"武器工业", @"TJ", @"能源与动力工程", @"TK", @"原子能技术", @"TL", @"电工技术", @"TM", @"无线电电子学、电信技术", @"TN", @"自动化技术、计算机技术", @"TP", @"化学工业", @"TQ", @"轻工业、手工业", @"TS", @"建筑科学", @"TU", @"水利工程", @"TV", @"交通运输", @"U", @"航空、航天", @"V", @"环境科学、安全科学", @"X", @"综合性图书", @"Z", @"其他", @"#", nil];
        
        _filterDataSource = [NSMutableDictionary dictionary];
        _indexArr = [NSMutableArray array];
        
        [self sortData];
    });
}

- (void)sortData {
    _rawDataSource = [NSKeyedUnarchiver unarchiveObjectWithData:[[DBManager sharedManager] checkIfBookListExist:@"DefaultBookList"].bookList];
    
    for (NSInteger i = 0; i < [_rawDataSource count]; i++) {
        NSString *bookID = [self rawDataSource][i];
        DetailedBookInfo *detailedBookInfo = [[DBManager sharedManager] checkIfObjectExistsInDetailedBookInfo:bookID];
        
        NSString *borrowingID = detailedBookInfo.query_id;
        if (borrowingID == nil || borrowingID.length == 0) {
            NSMutableArray *others = [self.filterDataSource objectForKey:@"#"];
            if (others == nil) {
                others = [NSMutableArray arrayWithObject:@{@"title": detailedBookInfo.title,
                                                           @"id": detailedBookInfo.bookID}];
                [self.filterDataSource setObject:others forKey:@"#"];
                [self.indexArr addObject:@"#"];
            } else {
                [others addObject:@{@"title": detailedBookInfo.title,
                                    @"id": detailedBookInfo.bookID}];
            }
        } else {
            NSString *index;
            if ([@"TB, TD, TE, TF, TG, TH, TJ, TK, TL, TM, TP, TQ, TS, TU, TV" rangeOfString:[borrowingID substringWithRange:NSMakeRange(0, 2)]].location != NSNotFound) {
                index = [borrowingID substringWithRange:NSMakeRange(0, 2)];
            } else {
                index = [borrowingID substringWithRange:NSMakeRange(0, 1)];
            }
            NSMutableArray *mutArr = [self.filterDataSource objectForKey:index];
            if (mutArr == nil) {
                mutArr = [NSMutableArray arrayWithObject:@{@"title": detailedBookInfo.title,
                                                           @"id": detailedBookInfo.bookID,
                                                           @"query_id": detailedBookInfo.query_id}];
                [self.filterDataSource setObject:mutArr forKey:index];
                [self.indexArr addObject:index];
            } else {
                [mutArr addObject:@{@"title": detailedBookInfo.title,
                                    @"id": detailedBookInfo.bookID,
                                    @"query_id": detailedBookInfo.query_id}];
            }
        }
    }
    
    _sortedIndexArr = [self.indexArr sortedArrayUsingSelector:@selector(compare:)];
    if ([self.sortedIndexArr count] > 0) {
        if ([self.sortedIndexArr.firstObject isEqualToString:@"#"]) {
            NSMutableArray *tempSortedMutArr = [NSMutableArray array];
            for (NSInteger i = 1; i < [self.sortedIndexArr count]; i++) {
                [tempSortedMutArr addObject:[self.sortedIndexArr objectAtIndex:i]];
            }
            [tempSortedMutArr addObject:[self.sortedIndexArr objectAtIndex:0]];
            _sortedIndexArr = [NSArray arrayWithArray:tempSortedMutArr];
        }
    }
}

- (void)addItemWithIdentifier:(NSString *)identifier {
    DetailedBookInfo *detailedBookInfo = [[DBManager sharedManager] checkIfObjectExistsInDetailedBookInfo:identifier];
    if (detailedBookInfo != nil) {
        BOOL exist = NO;
        if (detailedBookInfo.query_id != nil && detailedBookInfo.query_id.length > 0) {
            NSString *query_id = detailedBookInfo.query_id;
            NSString *index;
            if ([@"TB, TD, TE, TF, TG, TH, TJ, TK, TL, TM, TP, TQ, TS, TU, TV" rangeOfString:[query_id substringWithRange:NSMakeRange(0, 2)]].location != NSNotFound) {
                index = [query_id substringWithRange:NSMakeRange(0, 2)];
            } else {
                index = [query_id substringWithRange:NSMakeRange(0, 1)];
            }
            NSMutableArray *mutArr = [self.filterDataSource objectForKey:index];
            if (mutArr == nil) {
                exist = NO;
                mutArr = [NSMutableArray arrayWithObject:@{@"title": detailedBookInfo.title,
                                                           @"id": detailedBookInfo.bookID,
                                                           @"query_id": detailedBookInfo.query_id}];
                [self.filterDataSource setObject:mutArr forKey:index];
                [self.indexArr addObject:index];
            } else {
                exist = YES;
                [mutArr addObject:@{@"title": detailedBookInfo.title,
                                    @"id": detailedBookInfo.bookID,
                                    @"query_id": detailedBookInfo.query_id}];
            }
        } else {
            NSMutableArray *others = [self.filterDataSource objectForKey:@"#"];
            if (others == nil) {
                exist = NO;
                others = [NSMutableArray arrayWithObject:@{@"title": detailedBookInfo.title,
                                                           @"id": detailedBookInfo.bookID}];
                [self.filterDataSource setObject:others forKey:@"#"];
                [self.indexArr addObject:@"#"];
            } else {
                exist = YES;
                [others addObject:@{@"title": detailedBookInfo.title,
                                    @"id": detailedBookInfo.bookID}];
            }
        }
        if (exist == NO) {
            _sortedIndexArr = [self.indexArr sortedArrayUsingSelector:@selector(compare:)];
            if ([self.sortedIndexArr count] > 0) {
                if ([self.sortedIndexArr.firstObject isEqualToString:@"#"]) {
                    NSMutableArray *tempSortedMutArr = [NSMutableArray array];
                    for (NSInteger i = 1; i < [self.sortedIndexArr count]; i++) {
                        [tempSortedMutArr addObject:[self.sortedIndexArr objectAtIndex:i]];
                    }
                    [tempSortedMutArr addObject:[self.sortedIndexArr objectAtIndex:0]];
                    _sortedIndexArr = [NSArray arrayWithArray:tempSortedMutArr];
                }
            }
        }
    }
}

- (void)removeItemWithIdentifier:(NSString *)identifier {
    for (NSInteger i = 0; i < _sortedIndexArr.count; i++) {
        NSString *index = _sortedIndexArr[i];
        NSMutableArray *mutArr = _filterDataSource[index];
        BOOL exist = NO;
        for (NSInteger j = 0; j < mutArr.count; j++) {
            NSDictionary *dic = mutArr[j];
            if ([dic[@"id"] isEqualToString:identifier]) {
                exist = YES;
                if (mutArr.count > 1) {
                    [mutArr removeObjectAtIndex:j];
                } else {
                    NSMutableArray *tempMutArr = [NSMutableArray arrayWithArray:_sortedIndexArr];
                    [tempMutArr removeObjectAtIndex:i];
                    _sortedIndexArr = [NSArray arrayWithArray:tempMutArr];
                    [_filterDataSource removeObjectForKey:index];
                    for (NSString *str in _indexArr) {
                        if ([str isEqualToString:index]) {
                            [_indexArr removeObject:str];
                            break;
                        }
                    }
                }
                break;
            }
        }
        if (exist == YES) {
            break;
        }
    }
}

@end
