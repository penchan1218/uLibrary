//
//  HomeViewController.m
//  Library
//
//  Created by 陈颖鹏 on 14-10-11.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "HomeViewController.h"
#import "SearchResultsViewController.h"
#import "DetailsViewController.h"
#import "RightDrawer.h"
#import "DBManager.h"
#import "NWManager.h"
#import "MBProgressHUD.h"
#import "EverSearchView.h"
#import "RecommendedBookListViewController.h"
#import "MobClick.h"
#import "HomeView.h"
#import "LoginView.h"
#import "ScanningCodeViewController.h"
#import "RightDrawerDS.h"
#import "LoginHelpViewController.h"

@interface HomeViewController () {
    float largeFontSize;
    float mediumFontSize;
    float littleFontSize;
}

@property (weak, nonatomic) EverSearchView *everSearchView;
@property (weak, nonatomic) HomeView *homeView;
@property (weak, nonatomic) RightDrawer *rightDrawer;

@property (weak, nonatomic) UISearchBar *searchBar;
@property (weak, nonatomic) UIButton *scanBtn;

@property (strong, nonatomic) NSMutableDictionary *bookListsInfo;

@property (nonatomic, assign) BOOL isRightDrawerOn;
@property (nonatomic, assign) CGRect keyboardFrame;

@property (strong, nonatomic) UISwipeGestureRecognizer *swipeGesture;

@end

@implementation HomeViewController

- (id)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = UIColorFromRGBA(247, 244, 244, 1.0);
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.title = @"有书";
        
        _isRightDrawerOn = NO;
        _keyboardFrame = CGRectZero;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = @"有书";
    if (_isRightDrawerOn == YES) {
        [_rightDrawer.tableView reloadData];
    } else {
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"收藏夹" style:UIBarButtonItemStylePlain target:self action:@selector(calloutRightDrawerByClick)] animated:YES];
    }
    [MobClick beginLogPageView:@"HomeView"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
    
//    TEST
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        LoginHelpViewController *loginHelpView = [[LoginHelpViewController alloc] init];
////        [self presentViewController:loginHelpView animated:YES completion:nil];
//        [self.navigationController pushViewController:loginHelpView animated:YES];
//    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.title = @"主页";
    [MobClick endLogPageView:@"HomeView"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _bookListsInfo = [NSMutableDictionary dictionary];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"DidCollectBookInDetailsView" object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note) {
        if (_isRightDrawerOn == YES) {
            [_rightDrawer addItemWithIdentifier:[note.userInfo objectForKey:@"id"]];
        }
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"DidRemoveBookInDetailsView" object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note) {
        if (_isRightDrawerOn == YES) {
            [_rightDrawer removeItemWithIdentifier:[note.userInfo objectForKey:@"id"]];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"TapOnBookListRecommendedImageView" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSString *name = [[note userInfo] objectForKey:@"name"];
        NSDictionary *dic = _bookListsInfo[name];
        if (dic != nil) {
            [MobClick event:@"booklist_recommend_activate"];
            RecommendedBookListViewController *recommedBookListView = [[RecommendedBookListViewController alloc] initWithTitle:dic[@"title"]];
            recommedBookListView.comment = dic[@"comment"];
            recommedBookListView.books = dic[@"books"];
            [self.navigationController pushViewController:recommedBookListView animated:YES];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"RequestForLoggingIn"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self loginBtnClicked];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"SearchBookAccordingtoEAN13"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self showSearchResults:[[note userInfo] objectForKey:@"code"]];
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ShowLoginHelpView" object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      LoginHelpViewController *helpView = [[LoginHelpViewController alloc] init];
                                                      [self.navigationController pushViewController:helpView animated:YES];
                                                  }];
    
    UILabel *attentionLabel = [[UILabel alloc] init];
    attentionLabel.numberOfLines = 0;
    attentionLabel.textColor = UIColorFromRGBA(68, 68, 68, 1.0);
    if (IPHONE6P_SCREEN) {
        attentionLabel.font = [UIFont systemFontOfSize:14.0f];
    } else {
        attentionLabel.font = [UIFont systemFontOfSize:12.0f];
    }
    
    attentionLabel.text = @"创造更好的借阅体验\n\n我们会珍视您的每一份建议，\n我们正在根据您的期望努力改进\n\n关注微博@有书先森";
    attentionLabel.textAlignment = NSTextAlignmentCenter;
    attentionLabel.backgroundColor = [UIColor clearColor];
    attentionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:attentionLabel];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|-17-[attentionLabel]"
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(attentionLabel)]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-(width_3_screen)-[attentionLabel]-(width_3_screen)-|"
                               options:0
                               metrics:@{@"width_3_screen": @([[UIScreen mainScreen] bounds].size.width/5)}
                               views:NSDictionaryOfVariableBindings(attentionLabel)]];
    
    
//    RightDrawer *rightDrawer = [[RightDrawer alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width*8/9, [[UIScreen mainScreen] bounds].size.height-64)];
    
    
    HomeView *homeView = [[HomeView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64)];
    _homeView = homeView;
    [_homeView setUp];
    [self.view addSubview:homeView];
    
    [self startLoadingRecommendedBookList];
    
    _searchBar = _homeView.searchBar;
    _searchBar.delegate = self;
    
    _scanBtn = _homeView.scanBtn;
    [_scanBtn addTarget:self action:@selector(scanBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    _swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(calloutRightDrawerByGesture)];
    _swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:_swipeGesture];
}

- (void)scanBtnClicked {
    ScanningCodeViewController *scanningView = [[ScanningCodeViewController alloc] init];
    [self presentViewController:scanningView animated:YES completion:nil];
}

- (void)startLoadingRecommendedBookList {
    for (NSInteger i = 0; i < 4; i++) {
        NWManager *manager = [[NWManager alloc] init];
        [manager getHomePageBookListWithTag:i withCompletionHandler:^(NSInteger status, NSDictionary *info) {
            if (status == 1) {
                NSString *imageURLStr = info[@"cover_image_url"];
                [_homeView.bookListRecommendedView setBookListImageWithURL:imageURLStr tag:i];
                
                [_homeView.bookListRecommendedView setBookListName:info[@"title"] tag:i];
                
                [_bookListsInfo setObject:@{@"title": info[@"title"],
                                            @"books": info[@"books"],
                                            @"comment": info[@"comment"]} forKey:[NSString stringWithFormat:@"bookrec0%ld", (unsigned long)(i+1)]];
            } else if (status == 0) {
                MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                [self.navigationController.view addSubview:HUD];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_mark"]];
                HUD.labelText = @"网络错误,稍后再试";
                [HUD show:YES];
                [HUD hide:YES afterDelay:1.0f];
            } else if (status == -1) {
                MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                [self.navigationController.view addSubview:HUD];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_mark"]];
                HUD.labelText = @"请检查你的网络连接";
                [HUD show:YES];
                [HUD hide:YES afterDelay:1.0f];
            }
        }];
    }

}

- (void)loginBtnClicked {
    LoginView *loginView = [[LoginView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:loginView];
    [loginView showWithCompletionHandler:nil];
}

- (void)calloutRightDrawerByGesture {
    [MobClick event:@"favorite_activate_home"];
    [self handleDrawer];
}

- (void)calloutRightDrawerByClick {
    [MobClick event:@"favorite_home_click"];
    [self handleDrawer];
}

- (void)handleDrawer {
    if (_isRightDrawerOn) {
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
        _isRightDrawerOn = NO;
        [self.view addGestureRecognizer:_swipeGesture];
        _searchBar.userInteractionEnabled = YES;
        
        [_rightDrawer hideWithCompletionHandler:^{
            [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"收藏夹" style:UIBarButtonItemStylePlain target:self action:@selector(calloutRightDrawerByClick)] animated:YES];
        }];
        _rightDrawer = nil;
    } else {
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
//        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
//        [self.navigationController.view addSubview:HUD];
//        [HUD show:YES];
        [_searchBar resignFirstResponder];
        self.view.userInteractionEnabled = NO;
        
        _isRightDrawerOn = YES;
        [self.view removeGestureRecognizer:_swipeGesture];
        _searchBar.userInteractionEnabled = NO;
        
        RightDrawer *rightDrawer = [[RightDrawer alloc] initWithFrame:self.view.bounds];
        _rightDrawer = rightDrawer;
        _rightDrawer.delegate = self;
        [_rightDrawer addedToSuperView:self.view];
        [_rightDrawer showWithCompletionHandler:^{
            UIBarButtonItem *editBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editRightDrawer)];
            [self.navigationItem setLeftBarButtonItem:editBarBtn animated:YES];
            
            UIBarButtonItem *closeBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(handleDrawer)];
            [self.navigationItem setRightBarButtonItem:closeBarBtn];
        }];
        
//        [HUD hide:YES];
        self.view.userInteractionEnabled = YES;
    }
}

- (void)editRightDrawer {
    if (_rightDrawer != nil) {
        if (_rightDrawer.tableView.editing == NO) {
            [_rightDrawer.tableView setEditing:YES animated:YES];
            UIBarButtonItem *doneBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(editRightDrawer)];
            [self.navigationItem setLeftBarButtonItem:doneBarBtn animated:YES];
        } else {
            [_rightDrawer.tableView setEditing:NO animated:YES];
            UIBarButtonItem *editBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editRightDrawer)];
            [self.navigationItem setLeftBarButtonItem:editBarBtn animated:YES];
        }
    }
}

- (void)showSearchResults:(NSString *)searchStr {
    NSLog(@"Search: %@", searchStr);
    SearchResultsViewController *searchResultsView = [[SearchResultsViewController alloc] initWithSearchString:searchStr];
    [self.navigationController pushViewController:searchResultsView animated:YES];
}

- (void)keyboardDidShow:(NSNotification *)notif {
    NSDictionary *userInfo = [notif userInfo];
    self.keyboardFrame = [[userInfo objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue];
}

- (void)keyboardDidChangeFrame:(NSNotification *)notif {
    NSDictionary *userInfo = [notif userInfo];
    self.keyboardFrame = [[userInfo objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue];
}

- (void)setKeyboardFrame:(CGRect)keyboardFrame {
    _keyboardFrame = keyboardFrame;
    if (_everSearchView != nil) {
        _everSearchView.frame = CGRectMake(_everSearchView.frame.origin.x, _everSearchView.frame.origin.y, _everSearchView.frame.size.width, [[UIScreen mainScreen] bounds].size.height-44-64-keyboardFrame.size.height);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_isRightDrawerOn) {
        [self handleDrawer];
    }
    [_searchBar resignFirstResponder];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"%@", keyPath);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RightDrawer

- (void)rightDrawerDidSelectTheBookWithIdentifier:(NSString *)identifier {
    DetailsViewController *detailView = [[DetailsViewController alloc]
                                         initWithIdentifier:identifier];
    [self.navigationController pushViewController:detailView animated:YES];
}

#pragma mark - SearchBar

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    //避免当eversearchview出现并滑动的时候露出下层
    [_homeView scrollRectToVisible:CGRectMake(0, 0, _homeView.frame.size.width, _homeView.frame.size.height) animated:NO];
    _homeView.scrollEnabled = NO;
    
    //显示cancel按钮并改变其文字
    _scanBtn.alpha = 0.0f;
    searchBar.showsCancelButton = YES;
    for (UIView *view in [[[_searchBar subviews] firstObject] subviews]) {
        if ([view isKindOfClass:[NSClassFromString(@"UINavigationButton") class]]) {
            UIButton *btn = (UIButton *)view;
            [btn setTitle:@"取消" forState:UIControlStateNormal];
        }
    }
    
    EverSearchView *everSearchView = [[EverSearchView alloc] initWithFrame:CGRectMake(0, 44, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-44-64)];
    _everSearchView = everSearchView;
    [[NSNotificationCenter defaultCenter] addObserverForName:@"EverSearchViewDidSelect"
                                                      object:_everSearchView
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      NSString *searchStr = [note.userInfo objectForKey:@"term"];
                                                      [searchBar resignFirstResponder];
                                                      [self showSearchResults:searchStr];
                                                  }];
    [_homeView addSubview:_everSearchView];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_everSearchView setFilterTerm:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    //判断搜索历史是否已存在
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
    _homeView.scrollEnabled = YES;
    _scanBtn.alpha = 1.0f;
    searchBar.showsCancelButton = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"EverSearchViewDidSelect" object:_everSearchView];
    [_everSearchView removeFromSuperview];
    _everSearchView = nil;
}

@end
