//
//  HomeView.h
//  uLibrary
//
//  Created by 陈颖鹏 on 14/12/13.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookListRecommendedView.h"
#import "MyBorrowingView.h"
#import "LibraryCollectionView.h"
#import "NotBorrowView.h"
#import "DidBorrowView.h"

@interface HomeView : UIScrollView

@property (weak, nonatomic) UISearchBar *searchBar;
@property (weak, nonatomic) UIButton *scanBtn;

@property (weak, nonatomic) UIView *shelterView;
@property (weak, nonatomic) BookListRecommendedView *bookListRecommendedView;
@property (weak, nonatomic) NotBorrowView *notBorrowView;
@property (weak, nonatomic) DidBorrowView *didBorrowView;
@property (weak, nonatomic) LibraryCollectionView *libraryCollectionView;

- (void)setUp;

- (void)showNotBorrowView;

- (void)showDidBorrowView;

@end
