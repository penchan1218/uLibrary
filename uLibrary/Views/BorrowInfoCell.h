//
//  BorrowInfoCell.h
//  uLibrary
//
//  Created by 陈颖鹏 on 15/3/7.
//  Copyright (c) 2015年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BorrowInfoCell : UITableViewCell

@property (weak, nonatomic) UILabel *title;
@property (weak, nonatomic) UILabel *expireDate;
@property (weak, nonatomic) UILabel *extraInfo;
@property (weak, nonatomic) UIButton *renew;
@property (weak, nonatomic) UIActivityIndicatorView *indicator;

- (void)commitRenewAnimation;
- (void)stopRenewAnimation;

@end
