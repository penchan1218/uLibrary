//
//  RecommendedBookListViewController.m
//  uLibrary
//
//  Created by 陈颖鹏 on 14/12/10.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "RecommendedBookListViewController.h"
#import "DBManager.h"
#import "BriefTableViewCell.h"
#import "DetailsViewController.h"
#import "NWManager.h"
#import "DetailsViewCollectBookDelegate.h"
#import "MBProgressHUD.h"
#import "MobClick.h"

@interface RecommendedBookListViewController () <DetailsViewCollectBookDelegate>

@property (strong, nonatomic) NSMutableDictionary *booksInDefaultBookList;
@property (strong, nonatomic) NSMutableArray *collectedMutArr;

@end

@implementation RecommendedBookListViewController

- (id)initWithTitle:(NSString *)title {
    self = [super init];
    if (self) {
        self.title = title;
        self.view.backgroundColor = [UIColor whiteColor];
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        _booksInDefaultBookList = [NSMutableDictionary dictionary];
        _collectedMutArr = [NSMutableArray array];
        [self prepareBeforeLoading];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"RecommendedBookListView"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"RecommendedBookListView"];
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

- (void)setComment:(NSString *)comment {
    _comment = [comment copy];
    
    _commentView = [[UIView alloc] init];
    _commentView.backgroundColor = UIColorFromRGBA(247, 244, 244, 1.0);
//    _commentView.translatesAutoresizingMaskIntoConstraints = NO;

    [_commentView addConstraints:[NSLayoutConstraint
                                  constraintsWithVisualFormat:@"H:[_commentView(width)]"
                                  options:0
                                  metrics:@{@"width": @([[UIScreen mainScreen] bounds].size.width)}
                                  views:NSDictionaryOfVariableBindings(_commentView)]];
//    [_commentView addConstraint:[NSLayoutConstraint
//                                 constraintWithItem:_commentView attribute:NSLayoutAttributeWidth
//                                 relatedBy:NSLayoutRelationEqual
//                                 toItem:nil attribute:NSLayoutAttributeNotAnAttribute
//                                 multiplier:0.0f constant:[[UIScreen mainScreen] bounds].size.width]];
    
    UILabel *introLabel = [[UILabel alloc] init];
    introLabel.backgroundColor = [UIColor clearColor];
    introLabel.font = [UIFont systemFontOfSize:14];
    introLabel.textColor = UIColorFromRGBA(95, 95, 95, 1.0);
    introLabel.text = @"推荐理由: ";
    introLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_commentView addSubview:introLabel];
    
    UILabel *commentLabel = [[UILabel alloc] init];
    commentLabel.backgroundColor = [UIColor clearColor];
    commentLabel.font = [UIFont systemFontOfSize:12];
    commentLabel.textColor = UIColorFromRGBA(68, 68, 68, 1.0);
    commentLabel.numberOfLines = 0;
    commentLabel.text = _comment;
    commentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_commentView addSubview:commentLabel];
    
    [_commentView addConstraints:[NSLayoutConstraint
                                  constraintsWithVisualFormat:@"V:|-17-[introLabel]-17-[commentLabel]-17-|"
                                  options:NSLayoutFormatAlignAllLeft
                                  metrics:0
                                  views:NSDictionaryOfVariableBindings(introLabel, commentLabel)]];
    [_commentView addConstraints:[NSLayoutConstraint
                                  constraintsWithVisualFormat:@"H:|-26.5-[commentLabel]-26.5-|"
                                  options:0
                                  metrics:nil
                                  views:NSDictionaryOfVariableBindings(commentLabel)]];
    
    CGSize size = [_commentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    _commentView.frame = CGRectMake(0, 0, _commentView.frame.size.width, size.height);
    
//    NSLog(@"%@", NSStringFromCGSize(size));
//    [_commentView setNeedsLayout];
//    [_commentView setNeedsUpdateConstraints];
//    [_commentView layoutIfNeeded];
}

- (void)setBooks:(NSArray *)books {
    _books = books;
    
    for (NSInteger i = 0; i < books.count; i++) {
        if ([_booksInDefaultBookList objectForKey:books[i][@"id"]] != nil) {
            [_collectedMutArr addObject:@(1)];
        } else {
            [_collectedMutArr addObject:@(0)];
        }
    }
    
    [self setUpTableView];
}

- (void)setUpTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64) style:UITableViewStyleGrouped];
    _tableView = tableView;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableHeaderView = _commentView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _books.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110.0f;
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
    
    NSDictionary *dic = _books[indexPath.row];
    
    __weak BriefTableViewCell *weakCell = cell;
    [weakCell.cover_imageView setImageWithURL:[NSURL URLWithString:dic[@"cover_image_url"]]];
    if ([[self collectedMutArr][indexPath.row] integerValue] == 1) {
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
    DetailsViewController *detailsView = [[DetailsViewController alloc]
                                          initWithIdentifier:_books[indexPath.row][@"id"]];
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
    NSInteger exists = [[self collectedMutArr][cell.indexpath.row] integerValue];
    if (exists == 1) {
        [collect_mark_imageView setImage:[UIImage imageNamed:@"not_collect_mark"]];
        [[DBManager sharedManager] removeObjectWithIdentifier:_books[cell.indexpath.row][@"id"] fromBookList:@"DefaultBookList"];
        [self collectedMutArr][cell.indexpath.row] = @(0);
        [_booksInDefaultBookList removeObjectForKey:_books[cell.indexpath.row][@"id"]];
    } else {
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.labelText = @"正在收藏";
        [HUD show:YES];
        
        __block MBProgressHUD *blockHUD = HUD;
        
        NWManager *manager = [[NWManager alloc] init];
        [manager getDetailedBookInfo:_books[cell.indexpath.row][@"id"] withCompletionHandler:^(NSInteger status, NSDictionary *jsonDic) {
            blockHUD.mode = MBProgressHUDModeCustomView;
            if (status == 1) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:jsonDic];
                [dic setObject:@"DefaultBookList" forKey:@"name"];
                [[DBManager sharedManager] addObjectToBookList:dic];
                
                blockHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick_mark"]];
                [blockHUD setLabelText:@"收藏成功"];
                [blockHUD hide:YES afterDelay:1.0f];
                
                [collect_mark_imageView setImage:[UIImage imageNamed:@"collect_mark"]];
                [self collectedMutArr][cell.indexpath.row] = @(1);
                [_booksInDefaultBookList setObject:@(1) forKey:_books[cell.indexpath.row][@"id"]];
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

#pragma mark - DetailsView

- (void)didCollectBookInDetailsViewAtIndexPath:(NSIndexPath *)indexpath {
    [_booksInDefaultBookList setObject:@(1) forKey:_books[indexpath.row][@"id"]];
    _collectedMutArr[indexpath.row] = @(1);
    [_tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)didRemoveBookInDetailsView:(NSIndexPath *)indexpath {
    [_booksInDefaultBookList removeObjectForKey:_books[indexpath.row][@"id"]];
    _collectedMutArr[indexpath.row] = @(0);
    [_tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
}

@end
