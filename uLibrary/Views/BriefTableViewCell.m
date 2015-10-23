//
//  BriefTableViewCell.m
//  Library
//
//  Created by 陈颖鹏 on 14-10-11.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "BriefTableViewCell.h"

@implementation BriefTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addConstraintsToSelf];
    }
    return self;
}

- (void)addConstraintsToSelf {
    UIImageView *imageView = [[UIImageView alloc] init];
    _cover_imageView = imageView;
    _cover_imageView.clipsToBounds = YES;
    _cover_imageView.contentMode = UIViewContentModeScaleAspectFit;
//    _cover_imageView.contentMode = UIViewContentModeScaleAspectFill;
    _cover_imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_cover_imageView];
    
    UIImageView *collect_mark = [[UIImageView alloc] init];
    _collect_mark_imageView = collect_mark;
    _collect_mark_imageView.userInteractionEnabled = YES;
    _collect_mark_imageView.clipsToBounds = YES;
    _collect_mark_imageView.contentMode = UIViewContentModeCenter;
    _collect_mark_imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_collect_mark_imageView];
    
    UIView *infoView = [[UIView alloc] init];
    _infoView = infoView;
    _infoView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_infoView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    _titleLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:14.0f];
    _titleLabel.textColor = UIColorFromRGBA(44, 44, 44, 1.0f);
//    _titleLabel.font = [UIFont systemFontOfSize:15.0f];
    _titleLabel.numberOfLines = 2;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_infoView addSubview:_titleLabel];
    
    UILabel *authorLabel = [[UILabel alloc] init];
    _authorLabel = authorLabel;
    _authorLabel.textColor = UIColorFromRGBA(98, 98, 98, 1.0f);
//    _authorLabel.font = [UIFont systemFontOfSize:12.0f];
    _authorLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:12.0f];
    _authorLabel.numberOfLines = 2;
    _authorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_infoView addSubview:_authorLabel];
    
    UILabel *pressLabel = [[UILabel alloc] init];
    _pressLabel = pressLabel;
    _pressLabel.textColor = UIColorFromRGBA(98, 98, 98, 1.0f);
//    _pressLabel.font = [UIFont systemFontOfSize:12.0f];
    _pressLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:12.0f];
    _pressLabel.numberOfLines = 2;
    _pressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_infoView addSubview:_pressLabel];
    
    UIView *separatorView = [[UIView alloc] init];
    separatorView.backgroundColor = UIColorFromRGBA(220, 220, 220, 1.0);
    separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:separatorView];
    
    CGFloat scale_width = [[UIScreen mainScreen] bounds].size.width/320.0f;
    CGFloat scale_height = [[UIScreen mainScreen] bounds].size.height/568.0f;
    
    [_infoView addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|[_titleLabel]-(height_6)-[_authorLabel]-(height_6)-[_pressLabel]|"
                               options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                               metrics:@{@"height_6": @(6*scale_height)}
                               views:NSDictionaryOfVariableBindings(_titleLabel, _authorLabel, _pressLabel)]];
    [_infoView addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|[_titleLabel]|"
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(_titleLabel)]];
    
    
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:_infoView attribute:NSLayoutAttributeCenterY
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView attribute:NSLayoutAttributeCenterY
                                     multiplier:1.0f constant:0.0f]];
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:|-(width_7_5)-[_cover_imageView]-(width_7_5)-[_infoView]-(width_6_5)-[_collect_mark_imageView]-(width_12)-|"
                                      options:NSLayoutFormatAlignAllCenterY
                                      metrics:@{@"width_7_5": @(7.5*scale_width),
                                                @"width_6_5": @(6.5*scale_width),
                                                @"width_12": @(12*scale_width)}
                                      views:NSDictionaryOfVariableBindings(_cover_imageView, _infoView, _collect_mark_imageView)]];
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:_cover_imageView attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView attribute:NSLayoutAttributeHeight
                                     multiplier:1.0f constant:-12.0f]];
    [_cover_imageView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:_cover_imageView attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:_cover_imageView attribute:NSLayoutAttributeWidth
                                     multiplier:1.0f constant:0.0f]];
    
    [_collect_mark_imageView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:[_collect_mark_imageView(width_32)]"
                                      options:0
                                      metrics:@{@"width_32": @(32*scale_width)}
                                      views:NSDictionaryOfVariableBindings(_collect_mark_imageView)]];
    [_collect_mark_imageView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:[_collect_mark_imageView(width_32)]"
                                      options:0
                                      metrics:@{@"width_32": @(32*scale_width)}
                                      views:NSDictionaryOfVariableBindings(_collect_mark_imageView)]];
    
//    [_cover_imageView addConstraints:[NSLayoutConstraint
//                                      constraintsWithVisualFormat:@"H:[_cover_imageView(width_98)]"
//                                      options:0
//                                      metrics:@{@"width_98": @(98*scale_width)}
//                                      views:NSDictionaryOfVariableBindings(_cover_imageView)]];
//    [_cover_imageView addConstraints:[NSLayoutConstraint
//                                      constraintsWithVisualFormat:@"V:[_cover_imageView(width_98)]"
//                                      options:0
//                                      metrics:@{@"width_98": @(98*scale_width)}
//                                      views:NSDictionaryOfVariableBindings(_cover_imageView)]];
    
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:_infoView attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationLessThanOrEqual
                                     toItem:self.contentView attribute:NSLayoutAttributeHeight
                                     multiplier:1.0f constant:0.0f]];
    
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:|-(width_7)-[separatorView]-(width_8)-|"
                                      options:0
                                      metrics:@{@"width_7": @(7*scale_width),
                                                @"width_8": @(8*scale_width)}
                                      views:NSDictionaryOfVariableBindings(separatorView)]];
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:[separatorView(0.5)]|"
                                      options:0
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(separatorView)]];
}

@end
