//
//  RightDrawer.m
//  Library
//
//  Created by 陈颖鹏 on 14/11/6.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "RightDrawer.h"
#import "DBManager.h"
#import "RightDrawerDS.h"
#import "MobClick.h"

@interface RightDrawer () {
    UIColor *bgColor;
}

@property (weak, atomic) RightDrawerDS *shared_DS;

@property (nonatomic, assign) BOOL isGoingToBeShowed;

@end

@implementation RightDrawer

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        bgColor = [UIColor colorWithWhite:1 alpha:0.6];
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        
    }
    return self;
}

- (void)showWithCompletionHandler:(void (^)())completionHandler {
    [UIView animateWithDuration:0.10f animations:^{
        
        _blurView.alpha = 0.4f;
        _existing_view.alpha = 0.4f;
        _existing_view.frame = CGRectOffset(_existing_view.frame, -_existing_view.bounds.size.width*0.4, 0);
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.15f animations:^{
            
            _blurView.alpha = 1.0f;
            _existing_view.alpha = 1.0f;
            _existing_view.frame = CGRectOffset(_existing_view.frame, -_existing_view.bounds.size.width*0.6, 0);
            
        } completion:^(BOOL finished) {
            
            if (completionHandler != nil) {
                completionHandler();
            }
            
        }];
        
        _isGoingToBeShowed = YES;
        if (_tableView) {
            
            float delayTime = 0.0f;
            NSArray *onScreenCells = [_tableView indexPathsForRowsInRect:CGRectMake(0, 0, _tableView.frame.size.width, _tableView.frame.size.height)];
            for (NSInteger i = 0; i < onScreenCells.count; i++) {
                
                [self performSelector:@selector(showCellAtIndexPath:)
                           withObject:onScreenCells[i]
                           afterDelay:delayTime];
                delayTime += 0.03f;
                
            }
            
        }
    }];
}

- (void)showCellAtIndexPath:(NSIndexPath *)indexPath {
    [_tableView reloadRowsAtIndexPaths:@[indexPath]
                      withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)hideWithCompletionHandler:(void (^)())completionHandler {
    [UIView animateWithDuration:0.25f animations:^{
        
        _existing_view.frame = CGRectOffset(_existing_view.frame, _existing_view.bounds.size.width, 0);
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.25f animations:^{
            
            _blurView.alpha = 0.0f;
            
        } completion:^(BOOL finished) {
            
            [self removeFromSuperview];
            if (completionHandler != nil) {
                completionHandler();
            }
            
        }];
    }];
}

- (void)addedToSuperView:(UIView *)superView {
    _isGoingToBeShowed = NO;
    
    BlurView *blurView = [[BlurView alloc] initWithFrame:self.bounds];
    blurView.background = superView;
    _blurView = blurView;
    _blurView.alpha = 0.0f;
    [self addSubview:_blurView];
    
    BOOL haveBooks = ((NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:[[DBManager sharedManager] checkIfBookListExist:@"DefaultBookList"].bookList]).count > 0? YES: NO;
    if (haveBooks) {
        [self createTableView];
    } else {
        // 收藏夹中没有书, 出现提示
        [self createNoBooksView];
        
    }
    
    if (!self.superview) {
        [superView addSubview:self];
    }
    
    
    if (_tableView == _existing_view) {
        [self setup];
    }
}

- (void)createTableView {
    [_noBooksView removeFromSuperview];
    
    float origin_x = _isGoingToBeShowed? self.bounds.size.width/9: self.bounds.size.width;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(origin_x, 0, self.bounds.size.width*8/9, self.bounds.size.height) style:UITableViewStylePlain];
    _tableView = tableView;
    _tableView.alpha = _isGoingToBeShowed? 1.0f: 0.0f;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = bgColor;
    
    if (_isGoingToBeShowed) {
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    [self addSubview:_tableView];
    _existing_view = _tableView;
}

- (void)createNoBooksView {
    [_tableView removeFromSuperview];
    
    float origin_x = _isGoingToBeShowed? self.bounds.size.width/9: self.bounds.size.width;
    
    UIView *noBooksView = [[UIView alloc] initWithFrame:CGRectMake(origin_x, 0, self.bounds.size.width*8/9, self.bounds.size.height)];
    noBooksView.backgroundColor = bgColor;
    noBooksView.alpha = _isGoingToBeShowed? 1.0f: 0.0f;
    [self addSubview:noBooksView];
    _noBooksView = noBooksView;
    _existing_view = _noBooksView;
    
    UILabel *noBooksLabel = [[UILabel alloc] init];
    noBooksLabel.textAlignment = NSTextAlignmentCenter;
    noBooksLabel.textColor = UIColorFromRGBA(51, 51, 51, 1.0);
    noBooksLabel.text = @"您的收藏夹空空如也~";
    noBooksLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_noBooksView addSubview:noBooksLabel];
    
    [_noBooksView addConstraint:[NSLayoutConstraint
                                 constraintWithItem:_noBooksView attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:noBooksLabel attribute:NSLayoutAttributeCenterY
                                 multiplier:1.0f constant:20.0f]];
    [_noBooksView addConstraints:[NSLayoutConstraint
                                  constraintsWithVisualFormat:@"H:|[noBooksLabel]|"
                                  options:0
                                  metrics:nil
                                  views:NSDictionaryOfVariableBindings(noBooksLabel)]];
}

- (void)setup {
    _shared_DS = [RightDrawerDS sharedInstance];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView reloadData];
}

- (void)addItemWithIdentifier:(NSString *)identifier {
    if (!_tableView && [_shared_DS.sortedIndexArr count] > 0) {
        [self createTableView];
    }
}

- (void)removeItemWithIdentifier:(NSString *)identifier {
    if ([_shared_DS.sortedIndexArr count] == 0) {
        [self createNoBooksView];
    }
}

#pragma delegate - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _shared_DS.sortedIndexArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *index = [_shared_DS sortedIndexArr][section];
    NSMutableArray *mutArr = [_shared_DS filterDataSource][index];
    return mutArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    float scale = [[UIScreen mainScreen] bounds].size.width/320;
    if (section == 0) {
        return 52.0f;
    }
    return 39.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    float scale = [[UIScreen mainScreen] bounds].size.width/320;
    return 39.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BOOL first_section = section == 0? YES: NO;
    
    NSString *index = [_shared_DS sortedIndexArr][section];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, first_section? 52: 39)];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.clipsToBounds = YES;
    if ([index isEqualToString:@"#"]) {
        imageView.image = [UIImage imageNamed:@"Char_Others"];
    } else {
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Char_%@", index]];
    }
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = UIColorFromRGBA(76, 220, 99, 1.0);
    label.font = [UIFont systemFontOfSize:17.0f];
    label.text = [_shared_DS allIndexes][index];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:label];
    
    [view addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:|-(top)-[imageView]|"
                          options:0
                          metrics:@{@"top": @(first_section? 13: 0)}
                          views:NSDictionaryOfVariableBindings(imageView)]];
//    [view addConstraints:[NSLayoutConstraint
//                          constraintsWithVisualFormat:@"V:|-11-[label]-11-|"
//                          options:0
//                          metrics:nil
//                          views:NSDictionaryOfVariableBindings(label)]];
    [view addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-14-[imageView]-5-[label]-5-|"
                          options:NSLayoutFormatAlignAllCenterY
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(imageView, label)]];
    [imageView addConstraint:[NSLayoutConstraint
                              constraintWithItem:imageView attribute:NSLayoutAttributeWidth
                              relatedBy:NSLayoutRelationEqual
                              toItem:imageView attribute:NSLayoutAttributeHeight
                              multiplier:1.0f constant:0.0f]];
    
    NSLog(@"%d", first_section);
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.tag = 1000;
        titleLabel.font = [UIFont systemFontOfSize:15.0f];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:titleLabel];
        
        UILabel *idLabel = [[UILabel alloc] init];
        idLabel.tag = 1001;
        idLabel.font = [UIFont systemFontOfSize:13.0f];
        idLabel.textColor = UIColorFromRGBA(153, 153, 153, 1.0);
        idLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:idLabel];
        
        [cell.contentView addConstraints:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"H:|-17.5-[titleLabel(<=width)]-5-[idLabel]-(>=0)-|"
                                          options:NSLayoutFormatAlignAllCenterY
                                          metrics:@{@"width": @(_tableView.frame.size.width-100-22.5)}
                                          views:NSDictionaryOfVariableBindings(titleLabel, idLabel)]];
        [cell.contentView addConstraints:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"V:|-10.5-[titleLabel]-10.5-|"
                                          options:0
                                          metrics:nil
                                          views:NSDictionaryOfVariableBindings(titleLabel)]];
    }
    
    if (_isGoingToBeShowed == YES) {
        NSString *index = [_shared_DS sortedIndexArr][indexPath.section];
        NSMutableArray *mutArr = [_shared_DS filterDataSource][index];
        NSDictionary *data = mutArr[indexPath.row];
        
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:1000];
        UILabel *idLabel = (UILabel *)[cell viewWithTag:1001];
        
        idLabel.text = data[@"query_id"];
        nameLabel.text = data[@"title"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *index = [_shared_DS sortedIndexArr][indexPath.section];
    NSMutableArray *mutArr = [_shared_DS filterDataSource][index];
    NSDictionary *dic = [mutArr objectAtIndex:indexPath.row];
    [self.delegate rightDrawerDidSelectTheBookWithIdentifier:dic[@"id"]];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [MobClick event:@"collect_delete_home"];
        NSString *index = [_shared_DS sortedIndexArr][indexPath.section];
        NSMutableArray *mutArr = [_shared_DS filterDataSource][index];
        NSDictionary *dic = [mutArr objectAtIndex:indexPath.row];
        [[DBManager sharedManager] removeObjectWithIdentifier:dic[@"id"] fromBookList:@"DefaultBookList"];
//        if (mutArr.count == 1) {
//            [_shared_DS.filterDataSource removeObjectForKey:index];
//            NSMutableArray *tempMutArr = [NSMutableArray arrayWithArray:_shared_DS.sortedIndexArr];
//            [tempMutArr removeObjectAtIndex:indexPath.section];
//            _shared_DS.sortedIndexArr = tempMutArr;
//        } else {
//            [mutArr removeObjectAtIndex:indexPath.row];
//        }
        
        if ([_shared_DS.sortedIndexArr count] > 0) {
             [_tableView reloadData];
        } else {
            [self createNoBooksView];
        }
       
    }
}

-(NSString *)tableView:(UITableView*)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*)indexpath {
    return @"删除";
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 39;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

@end
