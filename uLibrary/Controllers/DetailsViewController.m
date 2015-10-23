//
//  DetailsViewController.m
//  Library
//
//  Created by 陈颖鹏 on 14-10-16.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "DetailsViewController.h"
#import "DetailsView.h"
#import "DBManager.h"
#import "NWManager.h"
#import "MBProgressHUD.h"
#import "ProgressBar.h"
#import "MobClick.h"

@interface DetailsViewController ()

@property (weak, nonatomic) DetailsView *detailsView;
@property (weak, nonatomic) ProgressBar *progressBar;

@property (strong, nonatomic) NSMutableDictionary *info;
@property (strong, nonatomic) NSMutableDictionary *booksInDefaultBookList;

@property (nonatomic, assign) BOOL loaded;
@property (nonatomic, assign) BOOL existInDefaultBookList;

@end

@implementation DetailsViewController

- (id)initWithIdentifier:(NSString *)identifier {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        _identifier = identifier;
        _booksInDefaultBookList = [NSMutableDictionary dictionary];
        [self prepareBeforeLoading];
        self.existInDefaultBookList = [self checkIfCollected];
        
        self.identifier = identifier;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"DetailsView"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"DetailsView"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_loaded == NO && _info == nil) {
        ProgressBar *progressBar = [[ProgressBar alloc] initWithFrame:CGRectMake(0, 0, 0, 3)];
        _progressBar = progressBar;
        [self.view addSubview:_progressBar];
        [_progressBar beginAnimating];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (BOOL)checkIfCollected {
    if (_booksInDefaultBookList[_identifier] != nil) {
        return YES;
    }
    return NO;
}

- (void)setIdentifier:(NSString *)identifier {
    _identifier = [identifier copy];
    [self setUp];
}

- (void)setExistInDefaultBookList:(BOOL)existInDefaultBookList {
    _existInDefaultBookList = existInDefaultBookList;
    if (existInDefaultBookList == YES) {
        //更换图标
        UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"large_collect_mark"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self action:@selector(rightBtnClicked)];
        self.navigationItem.rightBarButtonItem = rightBtn;
    } else {
        UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"large_not_collect_mark"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self action:@selector(rightBtnClicked)];
        self.navigationItem.rightBarButtonItem = rightBtn;
    }
}

- (void)setUp {
    DetailedBookInfo *book = [[DBManager sharedManager] checkIfObjectExistsInDetailedBookInfo:_identifier];
    if (book != nil) {
        _info = [NSMutableDictionary dictionaryWithDictionary:@{@"author": book.author,
                                                                @"publish": book.publish,
                                                                @"query_id": book.query_id,
                                                                @"isbn": book.isbn,
                                                                @"detail": book.detail,
                                                                @"cover_image_url": book.cover_image_url,
                                                                @"available": @(-1),
                                                                @"title": book.title,
                                                                @"id": book.bookID}];
        [self setUpDetailsView];
    }
    NWManager *manager = [[NWManager alloc] init];
    [manager getDetailedBookInfo:_identifier withCompletionHandler:^(NSInteger status, NSDictionary *jsonDic) {
        _loaded = YES;
        [_progressBar animatingCompleted];
        if (status == 1) {
            if (book == nil) {
                [[DBManager sharedManager] cacheBook:jsonDic];
                _info = [NSMutableDictionary dictionaryWithDictionary:jsonDic];
                [self setUpDetailsView];
            } else {
                NSInteger available = [jsonDic[@"available"] integerValue];
                if (available == 1) {
                    [_detailsView setRenewedDic:@{@"available": jsonDic[@"available"],
                                                  @"lib_info": jsonDic[@"lib_info"]}];
                } else if (available == 0) {
                    [_detailsView setRenewedDic:@{@"available": jsonDic[@"available"],
                                                  @"order_status": jsonDic[@"order_status"]}];
                }
                
            }
            
        } else if (status == 0) {
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:HUD];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_mark"]];
            HUD.labelText = @"网络错误,稍后再试";
            [HUD show:YES];
            [HUD hide:YES afterDelay:1.0f];
            
            if (book != nil) {
                [_detailsView updateLoadingViewAfterFailing];
            }
        } else if (status == -1) {
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:HUD];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_mark"]];
            HUD.labelText = @"请检查你的网络连接";
            [HUD show:YES];
            [HUD hide:YES afterDelay:1.0f];
            
            if (book != nil) {
                [_detailsView updateLoadingViewAfterFailing];
            }
        }
    }];
}

- (void)setUpDetailsView {
    DetailsView *detailsView = [[DetailsView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64)];
    _detailsView = detailsView;
    detailsView.model = _info;
    [self.view addSubview:detailsView];
}

- (void)addToCollection {
    [_info setObject:@"DefaultBookList" forKey:@"name"];
    [[DBManager sharedManager] addObjectToBookList:_info];
}

- (void)removeFromCollection {
    [[DBManager sharedManager] removeObjectWithIdentifier:_info[@"id"] fromBookList:@"DefaultBookList"];
}

- (void)rightBtnClicked {
    NSLog(@"Right bar button click");
    
    if (_info != nil) {
        if (_existInDefaultBookList == NO) {
            [MobClick event:@"collect_add_details"];
            [self addToCollection];
            
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:HUD];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick_mark"]];
            HUD.labelText = @"收藏成功";
            [HUD show:YES];
            [HUD hide:YES afterDelay:1.0f];
            
            if (self.delegate) {
                [self.delegate didCollectBookInDetailsViewAtIndexPath:self.indexpath];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DidCollectBookInDetailsView" object:self userInfo:@{@"id": _info[@"id"]}];
            
            self.existInDefaultBookList = YES;
        } else {
            [MobClick event:@"collect_delete_details"];
            [self removeFromCollection];
            
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:HUD];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick_mark"]];
            HUD.labelText = @"取消收藏成功";
            [HUD show:YES];
            [HUD hide:YES afterDelay:1.0f];
            
            if (self.delegate) {
                [self.delegate didRemoveBookInDetailsView:self.indexpath];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DidRemoveBookInDetailsView" object:self userInfo:@{@"id": _info[@"id"]}];
            
            self.existInDefaultBookList = NO;
        }
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
