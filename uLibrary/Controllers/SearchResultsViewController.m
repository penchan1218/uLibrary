//
//  SearchResultsViewController.m
//  Library
//
//  Created by 陈颖鹏 on 14/12/4.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "BriefTableViewCell.h"
#import "DetailsViewController.h"
#import "NWManager.h"
#import "MBProgressHUD.h"
#import "MJRefresh.h"
#import "ProgressBar.h"
#import "DBManager.h"
#import "EverSearchView.h"
#import "MobClick.h"

@interface SearchResultsViewController ()

@property (weak, nonatomic) ProgressBar *progressBar;
@property (weak, nonatomic) UISearchBar *searchBar;
@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) EverSearchView *everSearchView;

@property (strong, nonatomic) NSMutableArray *info;
@property (strong, nonatomic) NSMutableDictionary *booksInDefaultBookList;
@property (strong, nonatomic) NSMutableArray *collectedMutArr;

@property (nonatomic, assign) BOOL loaded;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) BOOL onlyOneBookCase;
@property (nonatomic, assign) CGRect keyboardFrame;
@property (nonatomic, assign) NSTimeInterval animationDuration;

@end

@implementation SearchResultsViewController

- (id)initWithSearchString:(NSString *)searchStr {
    self = [super init];
    if (self) {
        self.title = searchStr;
        self.view.backgroundColor = [UIColor whiteColor];
        self.searchStr = searchStr;
        
        _hasMore = YES;
        _loaded = NO;
        _onlyOneBookCase = NO;
        _keyboardFrame = CGRectZero;
        
        _info = [NSMutableArray array];
        _booksInDefaultBookList = [NSMutableDictionary dictionary];
        _collectedMutArr = [NSMutableArray array];
        
        [MobClick event:@"search_activate"];
        
        [self prepareBeforeLoading];
        
        if ([self checkIfCached] == NO) {
            [self startLoading];
        }
    }
    return self;
}

- (void)setSearchStr:(NSString *)searchStr {
    _searchStr = [searchStr copy];
    if (_searchBar != nil) {
        [_searchBar setText:_searchStr];
    }
}

- (void)setKeyboardFrame:(CGRect)keyboardFrame {
    _keyboardFrame = keyboardFrame;
    if (_everSearchView != nil) {
        _everSearchView.frame = CGRectMake(_everSearchView.frame.origin.x, _everSearchView.frame.origin.y, _everSearchView.frame.size.width, [[UIScreen mainScreen] bounds].size.height-44.5-64-_keyboardFrame.size.height);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = _searchStr;
    [MobClick beginLogPageView:@"SearchResultsView"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSInteger length = 8;
    if (_searchStr.length > length) {
        self.title = [[_searchStr substringWithRange:NSMakeRange(0, length)] stringByAppendingString:@"..."];
    }
    [MobClick endLogPageView:@"SearchResultsView"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_loaded == NO && _progressBar == nil) {
        ProgressBar *progressBar = [[ProgressBar alloc] initWithFrame:CGRectMake(0, 0, 0, 4)];
        _progressBar = progressBar;
        [self.view addSubview:_progressBar];
        [_progressBar beginAnimating];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIFont *font;
    if (IPHONE6P_SCREEN) {
        font = [UIFont systemFontOfSize:14.0f];
    } else {
        font = [UIFont systemFontOfSize:12.0f];
    }
    NSString *attentionText = @"创造更好的借阅体验\n\n我们会珍视您的每一份建议，\n我们正在根据您的期望努力改进\n\n关注微博@有书先森";
    
    UILabel *attentionLabel = [[UILabel alloc] init];
    attentionLabel.numberOfLines = 0;
    attentionLabel.textColor = UIColorFromRGBA(68, 68, 68, 1.0);
    attentionLabel.font = font;
    attentionLabel.text = attentionText;
    attentionLabel.textAlignment = NSTextAlignmentCenter;
    attentionLabel.backgroundColor = [UIColor clearColor];
    attentionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:attentionLabel];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|-60-[attentionLabel]"
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(attentionLabel)]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-(width_3_screen)-[attentionLabel]-(width_3_screen)-|"
                               options:0
                               metrics:@{@"width_3_screen": @([[UIScreen mainScreen] bounds].size.width/5)}
                               views:NSDictionaryOfVariableBindings(attentionLabel)]];
    
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64) style:UITableViewStyleGrouped];
    _tableView = tableView;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 44.5)];
    _searchBar = searchBar;
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.backgroundColor = UIColorFromRGBA(246, 246, 246, 1.0);
    _searchBar.delegate = self;
    self.tableView.tableHeaderView = _searchBar;
    
    for (UIView* subview in [[_searchBar.subviews lastObject] subviews]) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            UIImageView *imageview = (UIImageView*)subview;
            imageview.image = nil;
        }
    }
    
    [self.tableView addFooterWithTarget:self action:@selector(startLoading)];
    self.tableView.footerPullToRefreshText = @"上拉加载更多";
    self.tableView.footerReleaseToRefreshText = @"松开马上加载";
    self.tableView.footerRefreshingText = @"正在加载...";
}

- (void)prepareBeforeLoading {
    BookList *tempBookList = (BookList *)[[DBManager sharedManager] queryForObjectWithIdentifier:@"DefaultBookList"
                                                                     fromEntity:NSStringFromClass([BookList class])];
    NSArray *bookList = tempBookList == nil? nil: [NSKeyedUnarchiver unarchiveObjectWithData:tempBookList.bookList];
    if (bookList != nil) {
        for (NSInteger i = 0; i < bookList.count; i++) {
            NSString *tempBookID = bookList[i];
            [_booksInDefaultBookList setObject:@(1) forKey:tempBookID];
        }
    }
}

- (BOOL)checkIfCached {
    CachedSearchResults *cachedSearchResults = [[DBManager sharedManager] checkIfCachedSearchResultsExist:_searchStr];
    if (cachedSearchResults != nil) {
        _info = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:cachedSearchResults.searchResults]];
    
        for (NSInteger j = 0; j < _info.count; j++) {
            NSMutableArray *existArray = [NSMutableArray array];
            for (NSInteger i = 0; i < [_info[j] count]; i++) {
                if ([_booksInDefaultBookList objectForKey:_info[j][i][@"id"]] != nil) {
                    [existArray addObject:@(1)];
                } else {
                    [existArray addObject:@(0)];
                }
            }
            [_collectedMutArr addObject:existArray];
        }
        
        _loaded = YES;
        return YES;
    }
    return NO;
}

- (void)startLoading {
    if (_hasMore == YES && _onlyOneBookCase == NO) {
        NWManager *manager = [[NWManager alloc] init];
        NSUInteger searchPage = (_info == nil || _info.count == 0) ? 0 : _info.count;
        [manager getSearchResults:_searchStr searchPage:searchPage withCompletionHandler:^(NSInteger status, NSDictionary *jsonDic) {
            //表明搜索是否只有一个书目
            if (jsonDic[@"available"] != nil) {
                _onlyOneBookCase = YES;
                _hasMore = NO;
                _loaded = YES;
                [_progressBar animatingCompleted];
                
                [[DBManager sharedManager] cacheBook:jsonDic];
                
                DetailsViewController *detailsView = [[DetailsViewController alloc] initWithIdentifier:jsonDic[@"id"]];
                [self.navigationController pushViewController:detailsView animated:YES];
            } else {
                _loaded = YES;
                [_progressBar animatingCompleted];
                
                if (status == 1) {
                    _hasMore = [jsonDic[@"has_more"] boolValue];
                    NSArray *objectsInJsonDic = jsonDic[@"objects"];
                    if (_hasMore == NO && objectsInJsonDic.count == 0 && _info.count == 0) {
                        //这种情况是第一页就没有结果
                        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                        [self.navigationController.view addSubview:HUD];
                        HUD.mode = MBProgressHUDModeCustomView;
                        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_mark"]];
                        HUD.labelText = @"搜索不到相关书目";
                        [HUD show:YES];
                        [HUD hide:YES afterDelay:2.0f];
                        [self.tableView removeFooter];
                    } else if(_hasMore == NO && objectsInJsonDic.count == 0 && _info.count > 0) {
                        //这种情况是加载了缓存的结果后，下一页没有结果
                        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                        [self.navigationController.view addSubview:HUD];
                        HUD.mode = MBProgressHUDModeCustomView;
                        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_mark"]];
                        HUD.labelText = @"无更多书目";
                        [HUD show:YES];
                        [HUD hide:YES afterDelay:1.0f];
                        [self.tableView footerEndRefreshing];
                    } else {
                        NSArray *resultsInJsonDic = jsonDic[@"objects"];
                        
                        //检查书目是否已收藏
                        NSMutableArray *existArray = [NSMutableArray array];
                        for (NSInteger i = 0; i < resultsInJsonDic.count; i++) {
                            if ([_booksInDefaultBookList objectForKey:resultsInJsonDic[i][@"id"]] != nil) {
                                [existArray addObject:@(1)];
                            } else {
                                [existArray addObject:@(0)];
                            }
                        }
                        [_collectedMutArr addObject:existArray];
                        
                        [_info addObject:[NSArray arrayWithArray:resultsInJsonDic]];
                        
                        [[DBManager sharedManager] cacheSearchResults:@{@"name": _searchStr,
                                                                        @"searchResults": _info}];
                        
                        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:[_info count]-1] withRowAnimation:UITableViewRowAnimationFade];
                        [self.tableView footerEndRefreshing];
                    }
                } else if (status == 0) {
                    [self.tableView footerEndRefreshing];
                    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                    [self.navigationController.view addSubview:HUD];
                    HUD.mode = MBProgressHUDModeCustomView;
                    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_mark"]];
                    HUD.labelText = @"网络错误,稍后再试";
                    [HUD show:YES];
                    [HUD hide:YES afterDelay:1.0f];
                } else if (status == -1) {
                    [self.tableView footerEndRefreshing];
                    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                    [self.navigationController.view addSubview:HUD];
                    HUD.mode = MBProgressHUDModeCustomView;
                    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_mark"]];
                    HUD.labelText = @"请检查你的网络连接";
                    [HUD show:YES];
                    [HUD hide:YES afterDelay:1.0f];
                }
            }
        }];
    } else {
        [self.tableView footerEndRefreshing];
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.customView = [[UIView alloc] init];
        HUD.labelText = @"无更多书目";
        [HUD show:YES];
        [HUD hide:YES afterDelay:1.0f];
    }
}

- (void)keyboardDidShow:(NSNotification *)notif {
    NSDictionary *userInfo = [notif userInfo];
    self.keyboardFrame = [[userInfo objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue];
}

- (void)keyboardDidChangeFrame:(NSNotification *)notif {
    NSDictionary *userInfo = [notif userInfo];
    self.keyboardFrame = [[userInfo objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue];
}

#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_info count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self info][section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float scale = [[UIScreen mainScreen] bounds].size.width/320;
    return scale*110.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"BriefIdentifier";
    BriefTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[BriefTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(collectMarkClicked:)];
        [cell.collect_mark_imageView addGestureRecognizer:tapGesture];
    } else {
        cell.cover_imageView.image = nil;
    }
    
    cell.indexpath = indexPath;
    
    NSDictionary *dic = [self info][indexPath.section][indexPath.row];
    
    __weak BriefTableViewCell *weakCell = cell;
    [weakCell.cover_imageView setImageWithURL:[NSURL URLWithString:dic[@"cover_image_url"]]];
    if ([[self collectedMutArr][indexPath.section][indexPath.row] integerValue] == 1) {
        [cell.collect_mark_imageView setImage:[UIImage imageNamed:@"collect_mark"]];
    } else {
        [cell.collect_mark_imageView setImage:[UIImage imageNamed:@"not_collect_mark"]];
    }
    
    cell.titleLabel.text = dic[@"title"];
    cell.authorLabel.text = dic[@"author"];
    cell.pressLabel.text = dic[@"press"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"%@", [self info][indexPath.section][indexPath.row][@"id"]);
    DetailsViewController *detailsView = [[DetailsViewController alloc]
                                          initWithIdentifier:[self info][indexPath.section][indexPath.row][@"id"]];
    detailsView.indexpath = indexPath;
    detailsView.delegate = self;
    [self.navigationController pushViewController:detailsView animated:YES];
}

- (void)collectMarkClicked:(UIGestureRecognizer *)gesture {
    //找出对应的cell
    UIImageView *collect_mark_imageView = (UIImageView *)gesture.view;
    UIView *view = collect_mark_imageView;
    BriefTableViewCell *cell;
    while (YES) {
        static id tempView;
        tempView = view.superview;
        if ([[tempView class] isSubclassOfClass:[UITableViewCell class]]) {
            cell = tempView;
            break;
        } else {
            view = tempView;
        }
    }
    //判断是否已存在
    NSInteger exists = [[self collectedMutArr][cell.indexpath.section][cell.indexpath.row] integerValue];
    if (exists == 1) {
        [MobClick event:@"collect_delete_search"];
        [collect_mark_imageView setImage:[UIImage imageNamed:@"not_collect_mark"]];
        [[DBManager sharedManager] removeObjectWithIdentifier:[self info][cell.indexpath.section][cell.indexpath.row][@"id"] fromBookList:@"DefaultBookList"];
        [self collectedMutArr][cell.indexpath.section][cell.indexpath.row] = @(0);
        [_booksInDefaultBookList removeObjectForKey:[self info][cell.indexpath.section][cell.indexpath.row][@"id"]];
    } else {
        [MobClick event:@"collect_add_search"];
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.labelText = @"正在收藏";
        [HUD show:YES];
        
        __block MBProgressHUD *blockHUD = HUD;
        
        NWManager *manager = [[NWManager alloc] init];
        [manager getDetailedBookInfo:[self info][cell.indexpath.section][cell.indexpath.row][@"id"] withCompletionHandler:^(NSInteger status, NSDictionary *jsonDic) {
            blockHUD.mode = MBProgressHUDModeCustomView;
            if (status == 1) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:jsonDic];
                [dic setObject:@"DefaultBookList" forKey:@"name"];
                [[DBManager sharedManager] addObjectToBookList:dic];
                
                blockHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick_mark"]];
                [blockHUD setLabelText:@"收藏成功"];
                [blockHUD hide:YES afterDelay:1.0f];
                
                [collect_mark_imageView setImage:[UIImage imageNamed:@"collect_mark"]];
                [self collectedMutArr][cell.indexpath.section][cell.indexpath.row] = @(1);
                [_booksInDefaultBookList setObject:@(1) forKey:[self info][cell.indexpath.section][cell.indexpath.row][@"id"]];
            } else if (status == 0) {
                blockHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_mark"]];
                [blockHUD setLabelText:@"网络错误,请稍候再试"];
                [blockHUD hide:YES afterDelay:1.0f];
            } else if (status == -1) {
                blockHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_mark"]];
                [blockHUD setLabelText:@"请检查你的网络连接"];
                [blockHUD hide:YES afterDelay:1.0f];
            }
        }];
    }
}

#pragma mark - SearchBar

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    //显示cancel按钮并设置文本
    searchBar.showsCancelButton = YES;
    for (UIView *view in [[[_searchBar subviews] firstObject] subviews]) {
        if ([view isKindOfClass:[NSClassFromString(@"UINavigationButton") class]]) {
            UIButton *btn = (UIButton *)view;
            [btn setTitle:@"取消" forState:UIControlStateNormal];
        }
    }
    
    EverSearchView *everSearchView = [[EverSearchView alloc] initWithFrame:CGRectMake(0, 44.5, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-44.5-64)];
    _everSearchView = everSearchView;
    [[NSNotificationCenter defaultCenter] addObserverForName:@"EverSearchViewDidSelect"
                                                      object:_everSearchView
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      NSString *searchStr = [note.userInfo objectForKey:@"term"];
                                                      [searchBar resignFirstResponder];
                                                      [self showSearchResults:searchStr];
                                                  }];
    [self.view addSubview:_everSearchView];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_everSearchView setFilterTerm:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    NSString *searchStr = searchBar.text;
    BOOL exist = NO;
    NSInteger index = 0;
    NSMutableArray *everSearchResults = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"Ever_Search"]];
    for (NSInteger i = 0; i < everSearchResults.count; i++) {
        if ([searchStr isEqualToString:everSearchResults[i]]) {
            exist = YES;
            index = i;
            break;
        }
    }
    if (exist == YES) {
        [everSearchResults removeObjectAtIndex:index];
    }
    
    [everSearchResults insertObject:searchStr atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:everSearchResults forKey:@"Ever_Search"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self showSearchResults:searchStr];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"EverSearchViewDidSelect" object:_everSearchView];
    [_everSearchView removeFromSuperview];
    _everSearchView = nil;
}

- (void)showSearchResults:(NSString *)searchStr {
    [MobClick event:@"search_activate"];
    self.title = searchStr;
    self.searchStr = searchStr;
    _loaded = NO;
    _hasMore = YES;
    _onlyOneBookCase = NO;
    
    _info = [NSMutableArray array];
    _collectedMutArr = [NSMutableArray array];
    
    [self.tableView reloadData];
    
    if ([self checkIfCached] == NO) {
        [self startLoading];
    } else {
        [self.tableView reloadData];
    }
    
    if (_loaded == NO) {
        ProgressBar *progressBar = [[ProgressBar alloc] initWithFrame:CGRectMake(0, 0, 0, 4)];
        _progressBar = progressBar;
        [self.view addSubview:_progressBar];
        [_progressBar beginAnimating];
    }
}

#pragma mark - DetailsView

- (void)didCollectBookInDetailsViewAtIndexPath:(NSIndexPath *)indexpath {
    [_booksInDefaultBookList setObject:@(1) forKey:[self info][indexpath.section][indexpath.row][@"id"]];
    _collectedMutArr[indexpath.section][indexpath.row] = @(1);
    [_tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)didRemoveBookInDetailsView:(NSIndexPath *)indexpath {
    [_booksInDefaultBookList removeObjectForKey:[self info][indexpath.section][indexpath.row][@"id"]];
    _collectedMutArr[indexpath.section][indexpath.row] = @(0);
    [_tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
