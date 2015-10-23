//
//  HomeView.m
//  uLibrary
//
//  Created by 陈颖鹏 on 14/12/13.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "HomeView.h"
#import "MobClick.h"

@implementation HomeView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.alwaysBounceVertical = YES;
        self.showsVerticalScrollIndicator = NO;
    }
    return self;
}

- (void)setUp {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin) name:@"DidLogin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogout) name:@"DidLogout" object:nil];
    
    UIView *shelterView = [[UIView alloc] init];
    _shelterView = shelterView;
    _shelterView.backgroundColor = [UIColor whiteColor];
    _shelterView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_shelterView];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|[_shelterView(width)]|"
                          options:0
                          metrics:@{@"width": @(self.frame.size.width)}
                          views:NSDictionaryOfVariableBindings(_shelterView)]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:|[_shelterView(>=height)]|"
                          options:0
                          metrics:@{@"height": @(self.frame.size.height)}
                          views:NSDictionaryOfVariableBindings(_shelterView)]];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 44)];
    _searchBar = searchBar;
    _searchBar.placeholder = @"书名/ISBN/作者/出版社";
    _searchBar.backgroundColor = UIColorFromRGBA(246, 246, 246, 1.0);
    [_shelterView addSubview:_searchBar];
    
    for (UIView* subview in [[_searchBar.subviews lastObject] subviews]) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            UIImageView *imageview = (UIImageView*)subview;
            imageview.image = nil;
        }
    }
    
    
    UIButton *scanBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    _scanBtn = scanBtn;
    [_scanBtn setImage:[UIImage imageNamed:@"scan_code"] forState:UIControlStateNormal];
    _scanBtn.center = CGPointMake([[UIScreen mainScreen] bounds].size.width-40, _searchBar.center.y);
    [self addSubview:_scanBtn];
    
    BookListRecommendedView *bookListRecommendedView = [[BookListRecommendedView alloc] init];
    _bookListRecommendedView = bookListRecommendedView;
    _bookListRecommendedView.translatesAutoresizingMaskIntoConstraints = NO;
    [_shelterView addSubview:_bookListRecommendedView];
    [_bookListRecommendedView setUp];
    
    LibraryCollectionView *libraryCollectionView = [[LibraryCollectionView alloc] init];
    _libraryCollectionView = libraryCollectionView;
    _libraryCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [_shelterView addSubview:_libraryCollectionView];
    [_libraryCollectionView setUp];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user_name"] &&
        [[NSUserDefaults standardUserDefaults] objectForKey:@"user_code"]) {
        [MobClick event:@"use_login"];
        [self showDidBorrowView];
    } else {
        [MobClick event:@"use_logout"];
        [self showNotBorrowView];
    }
    
    [_shelterView addConstraints:[NSLayoutConstraint
                                  constraintsWithVisualFormat:@"V:[_searchBar]-7.25-[_bookListRecommendedView]-(>=0)-[_libraryCollectionView]-(>=10)-|"
                                  options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                  metrics:nil
                                  views:NSDictionaryOfVariableBindings(_searchBar, _bookListRecommendedView, _libraryCollectionView)]];
}

- (void)showNotBorrowView {
    if (_didBorrowView) {
        [_didBorrowView removeFromSuperview];
        _didBorrowView = nil;
    }
    
    NotBorrowView *notBorrowView = [[NotBorrowView alloc] init];
    _notBorrowView = notBorrowView;
    _notBorrowView.translatesAutoresizingMaskIntoConstraints = NO;
    [_shelterView addSubview:_notBorrowView];
    [_notBorrowView setUp];
    
    [_shelterView addConstraints:[NSLayoutConstraint
                                  constraintsWithVisualFormat:@"V:[_bookListRecommendedView]-(width)-[_notBorrowView]-(width)-[_libraryCollectionView]"
                                  options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                  metrics:@{@"width": @(IPHONE6_SCREEN||IPHONE6P_SCREEN? 20: 13)}
                                  views:NSDictionaryOfVariableBindings(_bookListRecommendedView, _notBorrowView, _libraryCollectionView)]];
}

- (void)showDidBorrowView {
    if (_notBorrowView) {
        [_notBorrowView removeFromSuperview];
        _notBorrowView = nil;
    }
    
    DidBorrowView *didBorrowView = [[DidBorrowView alloc] init];
    _didBorrowView = didBorrowView;
    didBorrowView.translatesAutoresizingMaskIntoConstraints = NO;
    [_shelterView addSubview:didBorrowView];
    [didBorrowView setUp];
    
    [_shelterView addConstraints:[NSLayoutConstraint
                                  constraintsWithVisualFormat:@"V:[_bookListRecommendedView]-(width)-[_didBorrowView]-(width)-[_libraryCollectionView]"
                                  options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                  metrics:@{@"width": @(IPHONE6_SCREEN||IPHONE6P_SCREEN? 20: 13)}
                                  views:NSDictionaryOfVariableBindings(_bookListRecommendedView, _didBorrowView, _libraryCollectionView)]];
}

- (void)didLogin {
    if (!_didBorrowView) {
        [self showDidBorrowView];
    }
}

- (void)didLogout {
    [self showNotBorrowView];
}

@end
