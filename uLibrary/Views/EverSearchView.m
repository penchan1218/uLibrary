//
//  EverSearchView.m
//  Library
//
//  Created by 陈颖鹏 on 14/12/1.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "EverSearchView.h"

@implementation EverSearchView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        cellHeight = 40.0f;
        
        // Get the ever searching terms
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Ever_Search"] == nil) {
            self.everSearching = [NSArray array];
        } else {
            _everSearching = [[NSUserDefaults standardUserDefaults] objectForKey:@"Ever_Search"];
        }
        _filterEverSearching = [_everSearching mutableCopy];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    if (_filterEverSearching.count == 0) {
        _hasEverSearchResults = NO;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(rect.size.width/10, rect.size.height/20, rect.size.width*0.8, rect.size.height/3)];
        _noEverSearchResultsLabel = label;
        _noEverSearchResultsLabel.textAlignment = NSTextAlignmentCenter;
        _noEverSearchResultsLabel.text = @"无搜索记录";
        [self addSubview:_noEverSearchResultsLabel];
    } else {
        _hasEverSearchResults = YES;
        UITableView *tableView = [[UITableView alloc] init];
        tableView.translatesAutoresizingMaskIntoConstraints = NO;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.rowHeight = cellHeight;
        tableView.sectionFooterHeight = 0.0f;
        tableView.backgroundColor = [UIColor whiteColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        [self addSubview:tableView];
        _tableView = tableView;
        
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:|[_tableView]|"
                              options:0
                              metrics:nil
                              views:NSDictionaryOfVariableBindings(_tableView)]];
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"H:|[_tableView]|"
                              options:0
                              metrics:nil
                              views:NSDictionaryOfVariableBindings(_tableView)]];
    }
}

- (void)setFilterTerm:(NSString *)term {
    _searchStr = term;
    if (_hasEverSearchResults == YES) {
        if (term == nil || term.length == 0) {
            _filterEverSearching = [_everSearching mutableCopy];
        } else {
            _filterEverSearching = [NSMutableArray array];
            for (NSInteger i = 0; i < [_everSearching count]; i++) {
                if ([_everSearching[i] rangeOfString:term].location != NSNotFound) {
                    [_filterEverSearching addObject:_everSearching[i]];
                }
            }
        }
        if (_filterEverSearching.count == 0) {
            _tableView.alpha = 0.0f;
            if (_noEverSearchResultsLabel == nil) {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/10, self.frame.size.height/20, self.frame.size.width*0.8, self.frame.size.height/3)];
                _noEverSearchResultsLabel = label;
                _noEverSearchResultsLabel.textAlignment = NSTextAlignmentCenter;
                _noEverSearchResultsLabel.text = @"无搜索记录";
                [self addSubview:_noEverSearchResultsLabel];
            }
        } else {
            _tableView.alpha = 1.0f;
            [_noEverSearchResultsLabel removeFromSuperview];
            [_tableView reloadData];
        }
    }
}

#pragma -
#pragma - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.filterEverSearching count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"everSearchingCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = self.filterEverSearching[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EverSearchViewDidSelect" object:self userInfo:@{@"term": [_filterEverSearching objectAtIndex:indexPath.row]}];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *everSearchResults = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"Ever_Search"]];
        if (_searchStr != nil && _searchStr.length > 0) {
            for (NSInteger i = 0, j = 0; i < everSearchResults.count; i++) {
                NSString *tempStr = everSearchResults[i];
                if ([tempStr rangeOfString:_searchStr].location != NSNotFound) {
                    if (j == indexPath.row) {
                        [everSearchResults removeObjectAtIndex:i];
                        break;
                    } else {
                        j++;
                    }
                }
            }
        } else {
            [everSearchResults removeObjectAtIndex:indexPath.row];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:everSearchResults forKey:@"Ever_Search"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        _everSearching = everSearchResults;
        [self setFilterTerm:_searchStr];
    }
}

-(NSString *)tableView:(UITableView*)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*)indexpath {
    return @"删除";
}

@end
