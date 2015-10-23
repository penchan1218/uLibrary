//
//  RecommendedBookListViewController.h
//  uLibrary
//
//  Created by 陈颖鹏 on 14/12/10.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecommendedBookListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (id)initWithTitle:(NSString *)title;

@property (strong, nonatomic) UIView *commentView;
@property (weak, nonatomic) UITableView *tableView;

@property (nonatomic, copy) NSString *comment;
@property (strong, nonatomic) NSArray *books;

@end
