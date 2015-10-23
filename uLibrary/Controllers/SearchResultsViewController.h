//
//  SearchResultsViewController.h
//  Library
//
//  Created by 陈颖鹏 on 14/12/4.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailsViewCollectBookDelegate.h"

@interface SearchResultsViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, DetailsViewCollectBookDelegate>

@property (nonatomic, copy) NSString *searchStr;

- (id)initWithSearchString:(NSString *)searchStr;

@end
