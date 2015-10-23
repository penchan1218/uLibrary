//
//  EverSearchView.h
//  Library
//
//  Created by 陈颖鹏 on 14/12/1.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EverSearchView : UIView <UITableViewDelegate, UITableViewDataSource> {
    float cellHeight;
}

@property (strong, nonatomic) NSArray *everSearching;
@property (strong, nonatomic) NSMutableArray *filterEverSearching;

@property (nonatomic, copy) NSString *searchStr;
@property (nonatomic, assign) BOOL hasEverSearchResults;

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UILabel *noEverSearchResultsLabel;

- (void)setFilterTerm:(NSString *)term;

@end
