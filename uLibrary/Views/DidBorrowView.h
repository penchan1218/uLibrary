//
//  DidBorrowView.h
//  uLibrary
//
//  Created by 陈颖鹏 on 15/3/4.
//  Copyright (c) 2015年 UniqueStudio. All rights reserved.
//

#import "MyBorrowingView.h"

@interface DidBorrowView : MyBorrowingView <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
    float cellHeight;
}

@property (weak, nonatomic) UILabel *tipsLabel;
@property (weak, nonatomic) UIButton *logoutBtn;
@property (weak, nonatomic) UIImageView *refreshImageView;
@property (weak, nonatomic) UIButton *shelterBtn;
@property (weak, nonatomic) UITableView *borrowingInfoTableView;

@property (strong ,nonatomic) NSMutableArray *theDataSource;

@property (nonatomic, assign) BOOL isRreshing;
@property (nonatomic, assign) BOOL isFolded;

@property (strong, nonatomic) NSLayoutConstraint *tableHeightConstraint;

@property (strong, nonatomic) NSTimer *loadingTooLongTimer;

- (void)operationsBeforeViewDisposed;

@end
