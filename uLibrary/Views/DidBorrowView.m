//
//  DidBorrowView.m
//  uLibrary
//
//  Created by 陈颖鹏 on 15/3/4.
//  Copyright (c) 2015年 UniqueStudio. All rights reserved.
//

#import "DidBorrowView.h"
#import "WSManager.h"
#import "BorrowInfoCell.h"
#import "HomeViewParameterH.h"
#import "HomeView.h"
#import "LocalNotificationManager.h"

@implementation DidBorrowView

- (void)setUp {
    [super setUp];
    
    _isRreshing = NO;
    _isFolded = YES;
    if (IPHONE6P_SCREEN) {
        cellHeight = 1.2*45;
    } else if (IPHONE6_SCREEN) {
        cellHeight = 1.2*45.0f;
    } else {
        cellHeight = 45.0f;
    }
    
    UIImageView *refreshImageView = [[UIImageView alloc] init];
    _refreshImageView = refreshImageView;
    _refreshImageView.image = [UIImage imageNamed:@"refresh"];
    _refreshImageView.userInteractionEnabled = NO;
    _refreshImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_refreshImageView];
    
    UILabel *tipsLabel = [[UILabel alloc] init];
    _tipsLabel = tipsLabel;
    _tipsLabel.font = [UIFont systemFontOfSize:FONT_SIZE_MEDIUM];
    _tipsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_tipsLabel];
    
    UIButton *shelterBtn = [[UIButton alloc] init];
    _shelterBtn = shelterBtn;
    [_shelterBtn addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventTouchUpInside];
    _shelterBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_shelterBtn];
    
    UIButton *logoutBtn = [[UIButton alloc] init];
    [logoutBtn setImage:[UIImage imageNamed:@"logout"] forState:UIControlStateNormal];
    [logoutBtn addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    logoutBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:logoutBtn];
    _logoutBtn = logoutBtn;
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:[myBorrowingLabel]-(>=0)-[_refreshImageView(25)]-10-[_logoutBtn(25)]-20-|"
                          options:NSLayoutFormatAlignAllCenterY
                          metrics:nil
                          views:@{@"myBorrowingLabel": self.myBorrowingLabel,
                                  @"_refreshImageView": _refreshImageView,
                                  @"_logoutBtn": _logoutBtn}]];
    [_refreshImageView addConstraint:[NSLayoutConstraint
                                      constraintWithItem:_refreshImageView attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:_refreshImageView attribute:NSLayoutAttributeHeight
                                      multiplier:1.0f constant:0.0f]];
    [_logoutBtn addConstraint:[NSLayoutConstraint
                               constraintWithItem:_logoutBtn attribute:NSLayoutAttributeWidth
                               relatedBy:NSLayoutRelationEqual
                               toItem:_logoutBtn attribute:NSLayoutAttributeHeight
                               multiplier:1.0f constant:0.0f]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:[myBorrowingLabel]-15-[_tipsLabel]"
                          options:0
                          metrics:nil
                          views:@{@"myBorrowingLabel": self.myBorrowingLabel,
                                  @"_tipsLabel": _tipsLabel}]];
    
    NSLayoutConstraint *constraint_tipsLabelNextToEdge = [NSLayoutConstraint
                                                          constraintWithItem:_tipsLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                                          toItem:self attribute:NSLayoutAttributeBottom
                                                          multiplier:1.0f constant:0.0f];
    constraint_tipsLabelNextToEdge.priority = 10;
    [self addConstraint:constraint_tipsLabelNextToEdge];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-20-[_tipsLabel]"
                          options:0
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(_tipsLabel)]];
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_shelterBtn attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:_refreshImageView attribute:NSLayoutAttributeCenterX
                         multiplier:1.0f constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_shelterBtn attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:_refreshImageView attribute:NSLayoutAttributeCenterY
                         multiplier:1.0f constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_shelterBtn attribute:NSLayoutAttributeWidth
                         relatedBy:NSLayoutRelationEqual
                         toItem:_refreshImageView attribute:NSLayoutAttributeWidth
                         multiplier:1.0f constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_shelterBtn attribute:NSLayoutAttributeHeight
                         relatedBy:NSLayoutRelationEqual
                         toItem:_refreshImageView attribute:NSLayoutAttributeHeight
                         multiplier:1.0f constant:0.0f]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self refreshAction];
    });
}

- (void)refreshAction {
    if (_isRreshing) {
        if (_loadingTooLongTimer) {
            [_loadingTooLongTimer invalidate];
            _loadingTooLongTimer = nil;
        }
        [self stopRefreshingAnimation];
        _tipsLabel.text = @"刷新失败，请重新尝试";
    } else {
        _loadingTooLongTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f
                                                                target:self
                                                              selector:@selector(loadingTooLongNoResponse)
                                                              userInfo:nil repeats:NO];
        [self refreshBorrowingInfo];
    }
}

- (void)refreshBorrowingInfo {
    if (_borrowingInfoTableView) {
        _borrowingInfoTableView.delegate = nil;
        _borrowingInfoTableView.dataSource = nil;
        [_borrowingInfoTableView removeFromSuperview];
        _borrowingInfoTableView = nil;
    }
    _tipsLabel.text = @"刷新中 . . .";
    
    [[LocalNotificationManager sharedInstance] removeAllLocalNotifications];
    
    //禁用刷新按钮同时使按钮旋转动画
    [self commitRefreshingAnimation];
    
    //再次请求获得个人借阅信息
    [[WSManager sharedManager] getCurrentWithCompletionHandler:^(NSArray *currentArr) {
        if (_loadingTooLongTimer) {
            [_loadingTooLongTimer invalidate];
            _loadingTooLongTimer = nil;
        }
        if (_isRreshing) {
            //停止刷新动画
            [self stopRefreshingAnimation];
            
            //回调重新布局
            if ([currentArr count] == 0) {
                _tipsLabel.text = @"我还没有借书呢，快去图书馆借书吧";
            } else if ([currentArr count] > 0) {
                NSLog(@"%@", currentArr);
                
                //测试数据部分
//                currentArr = @[@{@"query_id": @"TP312C 2065  c.3",
//                                 @"record_id": @"b2045534",
//                                 @"renew_id": @"i4124582",
//                                 @"status": @"过期 15-03-28",
//                                 @"title": @"测试"}];
                
                
                
                NSDateFormatter *day_dateFormatter = [[NSDateFormatter alloc] init];
                [day_dateFormatter setDateFormat:@"yyyy-MM-dd"];
                
                for (NSDictionary *aBook in currentArr) {
                    NSString *status = aBook[@"status"];
                    NSArray  *components = [status componentsSeparatedByString:@" "];
                    for (NSString *component in components) {
                        if ([component rangeOfString:@"-"].location != NSNotFound) {
                            
                            NSString *expiredDateString = [@"20" stringByAppendingString:component];
                            
                            NSDate *oneDayBeforeExpiredDate = [day_dateFormatter dateFromString:expiredDateString];
                            NSDate *twoDaysBeforeExpiredDay = [NSDate dateWithTimeInterval:-1*24*60*60
                                                                                 sinceDate:oneDayBeforeExpiredDate];
                            NSDate *threeDaysBeforeExpiredDay = [NSDate dateWithTimeInterval:-2*24*60*60
                                                                                   sinceDate:oneDayBeforeExpiredDate];
                            
                            if ([[NSDate dateWithTimeInterval:10*60*60 sinceDate:threeDaysBeforeExpiredDay] timeIntervalSinceDate:[NSDate date]] > 0) {
                                [[LocalNotificationManager sharedInstance] addLocalNotificationOnDate:[NSDate dateWithTimeInterval:10*60*60 sinceDate:threeDaysBeforeExpiredDay] level:3];
                            }
                            if ([[NSDate dateWithTimeInterval:10*60*60 sinceDate:twoDaysBeforeExpiredDay] timeIntervalSinceDate:[NSDate date]] > 0) {
                                [[LocalNotificationManager sharedInstance] addLocalNotificationOnDate:[NSDate dateWithTimeInterval:10*60*60 sinceDate:twoDaysBeforeExpiredDay] level:2];
                            }
                            if ([[NSDate dateWithTimeInterval:10*60*60 sinceDate:oneDayBeforeExpiredDate] timeIntervalSinceDate:[NSDate date]] > 0) {
                                [[LocalNotificationManager sharedInstance] addLocalNotificationOnDate:[NSDate dateWithTimeInterval:10*60*60 sinceDate:oneDayBeforeExpiredDate] level:1];
                            }
                            
                            NSDate *beginDate = [oneDayBeforeExpiredDate timeIntervalSinceDate:[NSDate date]] > 0? oneDayBeforeExpiredDate: [NSDate date];
                            for (NSInteger i = 1; i <= 10; i++) {
                                NSString *dateString = [day_dateFormatter stringFromDate:beginDate];
                                [[LocalNotificationManager sharedInstance] addLocalNotificationOnDate:[NSDate dateWithTimeInterval:i*24*60*60+10*60*60 sinceDate:[day_dateFormatter dateFromString:dateString]] level:1];
                            }
                            
                            break;
                        }
                    }
                }
                
                _theDataSource = [NSMutableArray arrayWithArray:currentArr];
                [self initializeTableView];
                [self adjustTableHeight];
            }
        }
    }];
}

- (void)initializeTableView {
    UITableView *tableView = [[UITableView alloc] init];
    tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    tableView.separatorColor = UIColorFromRGBA(211, 211, 211, 1.0);
    tableView.sectionHeaderHeight = 0.0f;
    tableView.rowHeight = cellHeight;
    tableView.sectionFooterHeight = 0.0f;
    tableView.scrollEnabled = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:tableView];
    _borrowingInfoTableView = tableView;
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:[myBorrowingLabel]-6-[_borrowingInfoTableView]"
                          options:0
                          metrics:nil
                          views:@{@"myBorrowingLabel": self.myBorrowingLabel,
                                  @"_borrowingInfoTableView": _borrowingInfoTableView}]];
    NSLayoutConstraint *constraint = [NSLayoutConstraint
                                      constraintWithItem:_borrowingInfoTableView attribute:NSLayoutAttributeBottom
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:self attribute:NSLayoutAttributeBottom
                                      multiplier:1.0f constant:0.0f];
    constraint.priority = 20;
    [self addConstraint:constraint];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-20-[_borrowingInfoTableView]-20-|"
                          options:0
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(_borrowingInfoTableView)]];
}

- (void)commitRefreshingAnimation {
    static float angle = 0.0f;
    
    float a,b,c,d,tx,ty;
    a = _refreshImageView.transform.a;
    b = _refreshImageView.transform.b;
    c = _refreshImageView.transform.c;
    d = _refreshImageView.transform.d;
    tx = _refreshImageView.transform.tx;
    ty = _refreshImageView.transform.ty;
    if (a == 1 && b == 0 && c == 0 &&
        d == 1 && tx == 0 && ty == 0) {
        angle = 0.0f;
    }
    angle += M_PI_2;
    
    _isRreshing = YES;
    
    [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _refreshImageView.transform = CGAffineTransformMakeRotation(angle);
                     } completion:^(BOOL finished) {
                         if (_isRreshing) {
                             [self commitRefreshingAnimation];
                         }
                     }];
}

- (void)stopRefreshingAnimation {
    _isRreshing = NO;
    [_refreshImageView.layer removeAllAnimations];
    _refreshImageView.transform = CGAffineTransformIdentity;
}

- (void)adjustTableHeight {
    if (_tableHeightConstraint) {
        [_borrowingInfoTableView removeConstraint:_tableHeightConstraint];
        _tableHeightConstraint = nil;
    }
    
    NSInteger rows = 0;
    if (_theDataSource.count <= 5) {
        rows = _theDataSource.count;
    } else {
        rows = _isFolded? 6: _theDataSource.count+1;
    }
    
    NSLayoutConstraint *tableHeightConstraint = [NSLayoutConstraint
                                                 constraintWithItem:_borrowingInfoTableView attribute:NSLayoutAttributeHeight
                                                 relatedBy:NSLayoutRelationEqual
                                                 toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                                 multiplier:0.0f constant:rows*cellHeight];
    [_borrowingInfoTableView addConstraint:tableHeightConstraint];
    _tableHeightConstraint = tableHeightConstraint;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_theDataSource.count <= 5) {
        return _theDataSource.count;
    }
    
    if (_isFolded) {
        return 6;
    }
    
    return _theDataSource.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_theDataSource.count > 5 &&
        ((indexPath.row == 5 && _isFolded) || (indexPath.row == _theDataSource.count && !_isFolded))) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FunctionalCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FunctionalCell"];
            
            UILabel *label = [[UILabel alloc] init];
            label.tag = 1001;
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.backgroundColor = UIColorFromRGBA(245, 245, 245, 1.0);
            label.textColor = UIColorFromRGBA(153, 153, 153, 1.0);
            label.font = [UIFont systemFontOfSize:FONT_SIZE_LITTLE];
            label.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:label];
            
            if (_isFolded) {
                label.text = @"查看更多";
            } else {
                label.text = @"收起";
            }
            
            [cell.contentView addConstraints:[NSLayoutConstraint
                                              constraintsWithVisualFormat:@"V:|-10-[label]|"
                                              options:0
                                              metrics:nil
                                              views:NSDictionaryOfVariableBindings(label)]];
            [cell.contentView addConstraints:[NSLayoutConstraint
                                              constraintsWithVisualFormat:@"H:|[label]|"
                                              options:0
                                              metrics:nil
                                              views:NSDictionaryOfVariableBindings(label)]];
        } else {
            UILabel *label = (UILabel *)[cell viewWithTag:1001];
        
            if (_isFolded) {
                label.text = @"查看更多";
            } else {
                label.text = @"收起";
            }
        }
        
        return cell;
    }
    BorrowInfoCell *cell;
    
    NSString *expireDateString = _theDataSource[indexPath.row][@"status"];
    NSString *actualExpireDateString;
    NSArray *separatedStringArr = [expireDateString componentsSeparatedByString:@" "];
    for (NSInteger i = 0; i < separatedStringArr.count; i++) {
        NSString *partString = separatedStringArr[i];
        if ([partString rangeOfString:@"-"].location != NSNotFound) {
            actualExpireDateString = [@"20" stringByAppendingString:partString];
            break;
        }
    }
    
    NSInteger leftDays = [self calculateDaysFromNowtoDate:actualExpireDateString];
    
    if ([expireDateString rangeOfString:@"已续借"].location == NSNotFound &&
        leftDays >= 0 && leftDays <= 2 &&
        [expireDateString rangeOfString:@"预约"].location == NSNotFound) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"AbleToRenewCell"];
        if (cell == nil) {
            cell = [[BorrowInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AbleToRenewCell"];
        } else {
            [cell stopRenewAnimation];
            [cell.renew removeTarget:self action:@selector(renewBook:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        cell.renew.tag = indexPath.row;
        [cell.renew addTarget:self action:@selector(renewBook:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"UnableToRenewCell"];
        if (cell == nil) {
            cell= [[BorrowInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UnableToRenewCell"];
        }
        
        if (leftDays > 0) {
            cell.extraInfo.text = [NSString stringWithFormat:@"%@天到期",
                                   [NSString stringWithFormat:@"%ld", (long)leftDays]];
        } else if (leftDays == 0) {
            cell.extraInfo.text = @"今天过期";
        } else {
            NSRange fineRange = [expireDateString rangeOfString:@" " options:NSBackwardsSearch];
            NSRange pointRange;
            if (fineRange.location != NSNotFound) {
                pointRange = [[expireDateString substringFromIndex:fineRange.location] rangeOfString:@"."];
            }
            
            if (fineRange.location != NSNotFound && pointRange.location != NSNotFound) {
                float fineNum = [[expireDateString substringFromIndex:fineRange.location+2] floatValue];
                cell.extraInfo.textColor = [UIColor redColor];
                cell.extraInfo.text = [NSString stringWithFormat:@"已欠费%.2f元", fineNum];
            } else {
                cell.extraInfo.textColor = UIColorFromRGBA(151, 151, 151, 1.0);
                cell.extraInfo.text = [NSString stringWithFormat:@"过期%ld天", (long)(-leftDays)];
            }
        }
    }
    
    cell.title.text = _theDataSource[indexPath.row][@"title"];
    
    NSArray *components = [expireDateString componentsSeparatedByString:@" "];
    NSMutableString *revised_expiredString = [NSMutableString string];
    for (NSInteger i = 0; i < components.count; i++) {
        NSString *component = components[i];
        if ([component rangeOfString:@"罚款"].location != NSNotFound) {
            break;
        } else {
            [revised_expiredString appendFormat:@" %@", component];
        }
    }
    
    cell.expireDate.text = revised_expiredString;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    _isFolded = !_isFolded;
    [self adjustTableHeight];
    [tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_theDataSource.count > 5 &&
        ((_isFolded && indexPath.row == 5) || (!_isFolded && indexPath.row == _theDataSource.count))) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)calculateDaysFromNowtoDate:(NSString *)toDateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *fromDate = [NSDate date];
    NSDate *toDate = [dateFormatter dateFromString:toDateString];
    NSTimeInterval seconds = [toDate timeIntervalSinceDate:fromDate];
    return seconds/60/60/24;
}

- (void)renewBook:(UIButton *)btn {
    NSInteger tag = btn.tag;
    
    BorrowInfoCell *cell = (BorrowInfoCell *)[_borrowingInfoTableView
                                              cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tag inSection:0]];
    [cell commitRenewAnimation];
    
    NSString *renewID = _theDataSource[tag][@"renew_id"];
    __weak typeof(self) weakSelf = self;
    [[WSManager sharedManager] renewBook:renewID withCompletionHandler:^(BOOL success, NSString *msg) {
        
        NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:_theDataSource[tag]];
        [newDic setObject:msg forKey:@"status"];
        [_theDataSource replaceObjectAtIndex:tag withObject:newDic];
        
        if (tag < 5 || !weakSelf.isFolded) {
            [weakSelf.borrowingInfoTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:tag inSection:0]]
                                                   withRowAnimation:UITableViewRowAnimationNone];
        }
        
    }];
}

- (void)logout {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"即将注销"
                                                        message:@"是否确认注销账号?"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确认", nil];
    [alertView show];
}

- (void)confirmLogout {
    [self operationsBeforeViewDisposed];
    
    [[LocalNotificationManager sharedInstance] removeAllLocalNotifications];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_name"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_code"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[WSManager sharedManager] disconnect];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidLogout" object:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self confirmLogout];
    }
}

- (void)loadingTooLongNoResponse {
    _loadingTooLongTimer = nil;
    _shelterBtn.userInteractionEnabled = NO;
    NSLog(@"loadingTooLongNoResponse---->>>>rerequest");
    _tipsLabel.text = @"刷新失败，将于3秒后再次刷新";
    [self stopRefreshingAnimation];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self refreshAction];
        _shelterBtn.userInteractionEnabled = YES;
    });
    
}

- (void)operationsBeforeViewDisposed {
    if (_loadingTooLongTimer) {
        [_loadingTooLongTimer invalidate];
        _loadingTooLongTimer = nil;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
