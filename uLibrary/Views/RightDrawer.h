//
//  RightDrawer.h
//  Library
//
//  Created by 陈颖鹏 on 14/11/6.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlurView.h"
#import "RightDrawerDelegate.h"

@interface RightDrawer : UIView <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UIView *noBooksView;

@property (weak, nonatomic) UIView *existing_view;

@property (weak, nonatomic) BlurView *blurView;

@property (weak, nonatomic) id<RightDrawerDelegate> delegate;

- (void)addedToSuperView:(UIView *)superView;

- (void)showWithCompletionHandler:(void (^)())completionHandler;

- (void)hideWithCompletionHandler:(void (^)())completionHandler;

- (void)addItemWithIdentifier:(NSString *)identifier;

- (void)removeItemWithIdentifier:(NSString *)identifier;

@end
