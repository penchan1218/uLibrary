//
//  BorrowInfoCell.m
//  uLibrary
//
//  Created by 陈颖鹏 on 15/3/7.
//  Copyright (c) 2015年 UniqueStudio. All rights reserved.
//

#import "BorrowInfoCell.h"
#import "HomeViewParameterH.h"

@implementation BorrowInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addConstraints];
    }
    return self;
}

- (void)addConstraints {
    UILabel *title = [[UILabel alloc] init];
    _title = title;
    _title.font = [UIFont systemFontOfSize:FONT_SIZE_MEDIUM];
    _title.textColor = UIColorFromRGBA(51, 51, 51, 1.0);
    _title.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_title];
    
    UILabel *expireDate = [[UILabel alloc] init];
    _expireDate = expireDate;
    _expireDate.textColor = UIColorFromRGBA(151, 151, 151, 1.0);
    _expireDate.font = [UIFont systemFontOfSize:FONT_SIZE_LITTLE];
    _expireDate.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_expireDate];
    
    
    if ([self.reuseIdentifier isEqualToString:@"AbleToRenewCell"]) {
        UIButton *renew = [[UIButton alloc] init];
        _renew = renew;
        _renew.layer.borderColor = THEME_GREEN.CGColor;
        _renew.layer.borderWidth = 1.0f;
        _renew.layer.cornerRadius = 5.0f;
        [_renew setTitle:@"续借" forState:UIControlStateNormal];
        _renew.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_LITTLE];
        [_renew setTitleColor:THEME_GREEN forState:UIControlStateNormal];
        _renew.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_renew];
    } else if ([self.reuseIdentifier isEqualToString:@"UnableToRenewCell"]) {
        UILabel *extraInfo = [[UILabel alloc] init];
        _extraInfo = extraInfo;
        _extraInfo.font = [UIFont systemFontOfSize:FONT_SIZE_LITTLE];
        _extraInfo.textColor = UIColorFromRGBA(151, 151, 151, 1.0);
        _extraInfo.textAlignment = NSTextAlignmentRight;
        _extraInfo.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_extraInfo];
    }
    
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:[_title]-6-[_expireDate]"
                                      options:NSLayoutFormatAlignAllLeft
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(_title, _expireDate)]];
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:_title attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView attribute:NSLayoutAttributeCenterY
                                     multiplier:1.0f constant:-3]];
    
    if ([self.reuseIdentifier isEqualToString:@"AbleToRenewCell"]) {
        [self.contentView addConstraints:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"H:|[_title]-40-[_renew(66)]|"
                                          options:0
                                          metrics:nil
                                          views:NSDictionaryOfVariableBindings(_title, _renew)]];
        [self.contentView addConstraint:[NSLayoutConstraint
                                         constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterY
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:_renew attribute:NSLayoutAttributeCenterY
                                         multiplier:1.0f constant:0.0f]];
        [self.contentView addConstraints:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"V:[_renew(24)]"
                                          options:0
                                          metrics:nil
                                          views:NSDictionaryOfVariableBindings(_renew)]];
    } else if ([self.reuseIdentifier isEqualToString:@"UnableToRenewCell"]) {
        [self.contentView addConstraints:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"H:|[_title(<=title_width)][_extraInfo]|"
                                          options:0
                                          metrics:@{@"title_width": @(0.625*[[UIScreen mainScreen] bounds].size.width)}
                                          views:NSDictionaryOfVariableBindings(_title, _extraInfo)]];
        [self.contentView addConstraint:[NSLayoutConstraint
                                         constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterY
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:_extraInfo attribute:NSLayoutAttributeCenterY
                                         multiplier:1.0f constant:0.0f]];
    }
    
}

- (void)commitRenewAnimation {
    _renew.alpha = 0.0f;
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicator = indicator;
    _indicator.center = _renew.center;
    [self.contentView addSubview:_indicator];
    [_indicator startAnimating];
}

- (void)stopRenewAnimation {
    _renew.alpha = 1.0f;
    [_indicator stopAnimating];
    [_indicator removeFromSuperview];
    _indicator = nil;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
