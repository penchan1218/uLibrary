//
//  DetailsView.m
//  Library
//
//  Created by 陈颖鹏 on 14-10-16.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "DetailsView.h"
#import "NWManager.h"

@interface DetailsView () {
    float largeFontSize;
    float mediumFontSize;
    float littleFontSize;
}

@property (nonatomic, assign) NSInteger available;

@property (weak, nonatomic) UIImageView *imageView;

@property (weak, nonatomic) UILabel *titleLabel;

@property (weak, nonatomic) UISegmentedControl *segmentedControl;

@property (weak, nonatomic) UILabel *authorLabel;

@property (weak, nonatomic) UILabel *publishLabel;

@property (weak, nonatomic) UILabel *query_idLabel;

@property (weak, nonatomic) UILabel *isbnLabel;

@property (weak, nonatomic) UILabel *detailLabel;

@property (weak, nonatomic) UIView *infoView;

@property (weak, nonatomic) UIView *collectionView;

@end

@implementation DetailsView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (IPHONE6_SCREEN) {
            largeFontSize = 25.0f;
            mediumFontSize = 16.0f;
            littleFontSize = 14.0f;
        } else if (IPHONE6P_SCREEN) {
            largeFontSize = 28.0f;
            mediumFontSize = 18.0f;
            littleFontSize = 16.0f;
        } else {
            largeFontSize = 20.0f;
            mediumFontSize = 14.0f;
            littleFontSize = 12.0f;
        }
    }
    return self;
}

- (void)setModel:(NSDictionary *)model {
    _model = model;
    
    [self addConstraintsToSelf];
    
    _available = [[self model][@"available"] integerValue];
    if (_available == -1) {
        UIView *view = [_collectionView.subviews firstObject];
        UILabel *label = (UILabel *)[view viewWithTag:1000];
        label.text = @"正在获取馆藏信息";
    } else if (_available == 0) {
        UIView *view = [_collectionView.subviews firstObject];
        UILabel *label = (UILabel *)[view viewWithTag:1000];
        label.text = [self model][@"order_status"];
    } else if (_available == 1) {
        [self layoutCollectionView:[self model][@"lib_info"]];
    }
    
    __weak typeof(self) weakSelf = self;
    [weakSelf.imageView setImageWithURL:[NSURL URLWithString:[self model][@"cover_image_url"]]];
    _titleLabel.text = [self model][@"title"];
    
    if ([self model][@"author"] != nil && [[self model][@"author"] length] > 0) {
        NSString *authorStr = [NSString stringWithFormat:@"作者: %@", [self model][@"author"]];
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:authorStr];
        [attributedStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGBA(51, 51, 51, 1.0) range:NSMakeRange(0, authorStr.length)];
        [attributedStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"STHeitiTC-Medium" size:mediumFontSize] range:NSMakeRange(0, 4)];
        [attributedStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"STHeitiTC-Light" size:mediumFontSize] range:NSMakeRange(4, authorStr.length-4)];
        _authorLabel.attributedText = attributedStr;
    }
    if ([self model][@"publish"] != nil && [[self model][@"publish"] length] > 0) {
        NSString *publishStr = [NSString stringWithFormat:@"出版社: %@", [self model][@"publish"]];
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:publishStr];
        [attributedStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGBA(51, 51, 51, 1.0) range:NSMakeRange(0, publishStr.length)];
        [attributedStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"STHeitiTC-Medium" size:mediumFontSize] range:NSMakeRange(0, 5)];
        [attributedStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"STHeitiTC-Light" size:mediumFontSize] range:NSMakeRange(5, publishStr.length-5)];
        _publishLabel.attributedText = attributedStr;
    }
    if ([self model][@"query_id"] != nil && [[self model][@"query_id"] length] > 0) {
        NSString *query_idStr = [NSString stringWithFormat:@"索书号: %@", [self model][@"query_id"]];
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:query_idStr];
        [attributedStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGBA(51, 51, 51, 1.0) range:NSMakeRange(0, query_idStr.length)];
        [attributedStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"STHeitiTC-Medium" size:mediumFontSize] range:NSMakeRange(0, 5)];
        [attributedStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"STHeitiTC-Light" size:mediumFontSize] range:NSMakeRange(5, query_idStr.length-5)];
        _query_idLabel.attributedText = attributedStr;
    }
    if ([self model][@"isbn"] != nil && [[self model][@"isbn"] length] > 0) {
        NSString *isbnStr = [NSString stringWithFormat:@"ISBN: %@", [self model][@"isbn"]];
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:isbnStr];
        [attributedStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGBA(51, 51, 51, 1.0) range:NSMakeRange(0, isbnStr.length)];
        [attributedStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"STHeitiTC-Medium" size:mediumFontSize] range:NSMakeRange(0, 6)];
        [attributedStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"STHeitiTC-Light" size:mediumFontSize] range:NSMakeRange(6, isbnStr.length-6)];
        _isbnLabel.attributedText = attributedStr;
    }
    if ([self model][@"detail"] != nil && [[self model][@"detail"] length] > 0) {
        NSString *detailStr = [NSString stringWithFormat:@"简介: %@", [self model][@"detail"]];
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:detailStr];
        [attributedStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGBA(51, 51, 51, 1.0) range:NSMakeRange(0, detailStr.length)];
        [attributedStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"STHeitiTC-Medium" size:mediumFontSize] range:NSMakeRange(0, 4)];
        [attributedStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"STHeitiTC-Light" size:mediumFontSize] range:NSMakeRange(4, detailStr.length-4)];
        _detailLabel.attributedText = attributedStr;
    }
    
    if (_available == 1) {
        for (NSInteger i = 0; i < _collectionView.subviews.count; i++) {
            NSDictionary *dic = [self model][@"lib_info"][i];
            UIView *view = [_collectionView subviews][i];
            UILabel *placeLabel = (UILabel *)[view viewWithTag:1000];
            placeLabel.text = dic[@"lib_location"];
            UILabel *infoLabel = (UILabel *)[view viewWithTag:1001];
            infoLabel.text = dic[@"lib_status"];
        }
    }
}

- (void)setRenewedDic:(NSDictionary *)renewedDic {
    _renewedDic = renewedDic;
    NSInteger available = [renewedDic[@"available"] integerValue];
    _available = available;
    if (_available == 0) {
        UIView *view = [_collectionView.subviews firstObject];
        UILabel *label = (UILabel *)[view viewWithTag:1000];
        label.text = renewedDic[@"order_status"];
    } else if (_available == 1) {
        [self layoutCollectionView:renewedDic[@"lib_info"]];
        for (NSInteger i = 0; i < _collectionView.subviews.count; i++) {
            NSDictionary *dic = renewedDic[@"lib_info"][i];
            UIView *view = [_collectionView subviews][i];
            UILabel *placeLabel = (UILabel *)[view viewWithTag:1000];
            placeLabel.text = dic[@"lib_location"];
            UILabel *infoLabel = (UILabel *)[view viewWithTag:1001];
            infoLabel.text = dic[@"lib_status"];
        }
    }
}

- (void)addConstraintsToSelf {
    UIImageView *imageView = [[UIImageView alloc] init];
    _imageView = imageView;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.clipsToBounds = YES;
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_imageView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont fontWithName:@"STHeitiTC-Medium" size:largeFontSize];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_titleLabel];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"图书描述", @"馆藏信息"]];
    _segmentedControl = segmentedControl;
    _segmentedControl.selectedSegmentIndex = 0;
    _segmentedControl.tintColor = UIColorFromRGBA(76, 220, 99, 1.0);
    _segmentedControl.backgroundColor = [UIColor whiteColor];
    _segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    [_segmentedControl addTarget:self action:@selector(segmentedControlIndexChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_segmentedControl];
    
    UIView *infoView = [[UIView alloc] init];
    _infoView = infoView;
    _infoView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_infoView];
    
    NSMutableArray *allViewsInsideInfoView = [NSMutableArray array];
    
    if ([self model][@"author"] != nil && [[self model][@"author"] length] > 0) {
        UILabel *authorLabel = [[UILabel alloc] init];
        _authorLabel = authorLabel;
        _authorLabel.numberOfLines = 0;
        _authorLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_infoView addSubview:_authorLabel];
        [allViewsInsideInfoView addObject:_authorLabel];
    }
    
    if ([self model][@"publish"] != nil && [[self model][@"publish"] length] > 0) {
        UILabel *publishLabel = [[UILabel alloc] init];
        _publishLabel = publishLabel;
        _publishLabel.numberOfLines = 0;
        _publishLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_infoView addSubview:_publishLabel];
        [allViewsInsideInfoView addObject:_publishLabel];
    }
    
    if ([self model][@"query_id"] != nil && [[self model][@"query_id"] length] > 0) {
        UILabel *query_idLabel = [[UILabel alloc] init];
        _query_idLabel = query_idLabel;
        _query_idLabel.numberOfLines = 0;
        _query_idLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_infoView addSubview:_query_idLabel];
        [allViewsInsideInfoView addObject:_query_idLabel];
    }
    
    if ([self model][@"isbn"] != nil && [[self model][@"isbn"] length] > 0) {
        UILabel *isbnLabel = [[UILabel alloc] init];
        _isbnLabel = isbnLabel;
        _isbnLabel.numberOfLines = 0;
        _isbnLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_infoView addSubview:_isbnLabel];
        [allViewsInsideInfoView addObject:_isbnLabel];
    }
    
    if ([self model][@"detail"] != nil && [[self model][@"detail"] length] > 0) {
        UILabel *detailLabel = [[UILabel alloc] init];
        _detailLabel = detailLabel;
        _detailLabel.numberOfLines = 0;
        _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_infoView addSubview:_detailLabel];
        [allViewsInsideInfoView addObject:_detailLabel];
    }

    float scale = [[UIScreen mainScreen] bounds].size.height/568;
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:[_titleLabel]-(height_17)-[_segmentedControl(22.5)]-(height_16)-[_infoView]-(>=5)-|"
                          options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                          metrics:@{@"height_17": @(17*scale),
                                    @"height_16": @(16*scale)}
                          views:NSDictionaryOfVariableBindings(_titleLabel, _segmentedControl, _infoView)]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:|-23-[_imageView(height_100)]-(height_20)-[_titleLabel]"
                          options:NSLayoutFormatAlignAllCenterX
                          metrics:@{@"height_100": @(100*scale),
                                    @"height_20": @(20*scale)}
                          views:NSDictionaryOfVariableBindings(_imageView, _titleLabel)]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_imageView
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:self attribute:NSLayoutAttributeCenterX
                         multiplier:1.0f constant:0.0f]];
    
    
    [_imageView addConstraint:[NSLayoutConstraint
                               constraintWithItem:_imageView attribute:NSLayoutAttributeHeight
                               relatedBy:NSLayoutRelationEqual
                               toItem:_imageView attribute:NSLayoutAttributeWidth
                               multiplier:1.0f constant:0.0f]];
    
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-20-[_titleLabel]-20-|"
                          options:0
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(_titleLabel)]];
    
    for (NSInteger i = 0; i < [allViewsInsideInfoView count]; i++) {
        if (i == 0) {
            UIView *firstView = [allViewsInsideInfoView firstObject];
            [_infoView addConstraints:[NSLayoutConstraint
                                       constraintsWithVisualFormat:@"V:|[firstView]"
                                       options:0
                                       metrics:nil
                                       views:NSDictionaryOfVariableBindings(firstView)]];
        } else {
            UIView *formmerView = allViewsInsideInfoView[i-1];
            UIView *latterView = allViewsInsideInfoView[i];
            [_infoView addConstraints:[NSLayoutConstraint
                                       constraintsWithVisualFormat:@"V:[formmerView]-(height_11)-[latterView]"
                                       options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                       metrics:@{@"height_11": @(11*scale)}
                                       views:NSDictionaryOfVariableBindings(formmerView, latterView)]];
        }
        if (i == [allViewsInsideInfoView count]-1) {
            UIView *lastView = [allViewsInsideInfoView lastObject];
            [_infoView addConstraints:[NSLayoutConstraint
                                       constraintsWithVisualFormat:@"V:[lastView]|"
                                       options:0
                                       metrics:nil
                                       views:NSDictionaryOfVariableBindings(lastView)]];
        }
    }
    
    if ([allViewsInsideInfoView count] > 0) {
        UIView *firstView = [allViewsInsideInfoView firstObject];
        [_infoView addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:|-3-[firstView]-3-|"
                                   options:0
                                   metrics:nil
                                   views:NSDictionaryOfVariableBindings(firstView)]];
    }
    
    
    UIView *colletionView = [[UIView alloc] init];
    _collectionView = colletionView;
    _collectionView.alpha = 0.0f;
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_collectionView];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:[_segmentedControl]-(height_16)-[_collectionView]-(>=5)-|"
                          options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                          metrics:@{@"height_16": @(16*scale)}
                          views:NSDictionaryOfVariableBindings(_segmentedControl, _collectionView)]];
    
    UIView *loadingView = [[UIView alloc] init];
    loadingView.translatesAutoresizingMaskIntoConstraints = NO;
    [_collectionView addSubview:loadingView];
    
    UILabel *loadingLabel = [[UILabel alloc] init];
    loadingLabel.tag = 1000;
    loadingLabel.font = [UIFont fontWithName:@"STHeitiTC-Medium" size:mediumFontSize];
    loadingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [loadingView addSubview:loadingLabel];
    
    [loadingView addConstraints:[NSLayoutConstraint
                                 constraintsWithVisualFormat:@"V:|[loadingLabel]-(height_12)-|"
                                 options:0
                                 metrics:@{@"height_12": @(12*scale)}
                                 views:NSDictionaryOfVariableBindings(loadingLabel)]];
    [loadingView addConstraints:[NSLayoutConstraint
                                 constraintsWithVisualFormat:@"H:|-3-[loadingLabel]-3-|"
                                 options:0
                                 metrics:nil
                                 views:NSDictionaryOfVariableBindings(loadingLabel)]];
    [_collectionView addConstraints:[NSLayoutConstraint
                                     constraintsWithVisualFormat:@"V:|[loadingView]"
                                     options:0
                                     metrics:nil
                                     views:NSDictionaryOfVariableBindings(loadingView)]];
    [_collectionView addConstraints:[NSLayoutConstraint
                                     constraintsWithVisualFormat:@"H:|[loadingView]|"
                                     options:0
                                     metrics:nil
                                     views:NSDictionaryOfVariableBindings(loadingView)]];
    
}

- (void)layoutCollectionView:(NSArray *)collection {
    [[_collectionView.subviews firstObject] removeFromSuperview];
    [_collectionView removeConstraints:[_collectionView constraints]];
    
    float scale = [[UIScreen mainScreen] bounds].size.height/568;
    
    NSArray *constraints = [NSLayoutConstraint
                            constraintsWithVisualFormat:@"V:[_segmentedControl]-(height_16)-[_collectionView]-(>=5)-|"
                            options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                            metrics:@{@"height_16": @(16*scale)}
                            views:NSDictionaryOfVariableBindings(_segmentedControl, _collectionView)];;
    [_collectionView removeFromSuperview];
    _collectionView = nil;
    [self removeConstraints:constraints];
    
    UIView *view = [[UIView alloc] init];
    _collectionView = view;
    if (_segmentedControl.selectedSegmentIndex == 0) {
        _collectionView.alpha = 0.0f;
    }
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_collectionView];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:[_segmentedControl]-(height_16)-[_collectionView]-(>=5)-|"
                          options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                          metrics:@{@"height_16": @(16*scale)}
                          views:NSDictionaryOfVariableBindings(_segmentedControl, _collectionView)]];
    
    for (NSInteger i = 0; i < collection.count; i++) {
        UIView *view = [[UIView alloc] init];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [_collectionView addSubview:view];
        
        UILabel *placeLabel = [[UILabel alloc] init];
        placeLabel.numberOfLines = 0;
        placeLabel.font = [UIFont fontWithName:@"STHeitiTC-Medium" size:mediumFontSize];
        placeLabel.textColor = UIColorFromRGBA(51, 51, 51, 1.0);
        placeLabel.tag = 1000;
        placeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [view addSubview:placeLabel];
        
        UILabel *infoLabel = [[UILabel alloc] init];
        infoLabel.numberOfLines = 0;
        infoLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:littleFontSize];
        infoLabel.textColor = UIColorFromRGBA(163, 163, 163, 1.0);
        infoLabel.tag = 1001;
        infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [view addSubview:infoLabel];
        
        [view addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"H:|-3-[placeLabel]-3-|"
                              options:0
                              metrics:nil
                              views:NSDictionaryOfVariableBindings(placeLabel)]];
        
        [view addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:|[placeLabel]-7-[infoLabel]-(height_12)-|"
                              options:NSLayoutFormatAlignAllLeft
                              metrics:@{@"height_12": @(12*scale)}
                              views:NSDictionaryOfVariableBindings(placeLabel, infoLabel)]];
        
        if (i == 0) {
            [_collectionView addConstraints:[NSLayoutConstraint
                                             constraintsWithVisualFormat:@"V:|[view]"
                                             options:0
                                             metrics:nil
                                             views:NSDictionaryOfVariableBindings(view)]];
            [_collectionView addConstraints:[NSLayoutConstraint
                                             constraintsWithVisualFormat:@"H:|[view]|"
                                             options:0
                                             metrics:nil
                                             views:NSDictionaryOfVariableBindings(view)]];
        } else {
            UIView *lastView = [_collectionView.subviews objectAtIndex:_collectionView.subviews.count-2];
            [_collectionView addConstraints:[NSLayoutConstraint
                                             constraintsWithVisualFormat:@"V:[lastView][view]"
                                             options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                             metrics:nil
                                             views:NSDictionaryOfVariableBindings(lastView, view)]];
        }
        
        if (i == collection.count-1) {
            [_collectionView addConstraints:[NSLayoutConstraint
                                             constraintsWithVisualFormat:@"V:[view]|"
                                             options:0
                                             metrics:nil
                                             views:NSDictionaryOfVariableBindings(view)]];
        }
    }
    
    [self setNeedsUpdateConstraints];
    [self layoutIfNeeded];
}

- (void)segmentedControlIndexChanged:(UISegmentedControl *)seg {
    NSInteger index = [seg selectedSegmentIndex];
    if (index == 1) {
        _collectionView.alpha = 1.0f;
        _infoView.alpha = 0.0f;
    } else {
        _collectionView.alpha = 0.0f;
        _infoView.alpha = 1.0f;
    }
}

- (void)updateLoadingViewAfterFailing {
    UILabel *loadingLabel = (UILabel *)[_collectionView viewWithTag:1000];
    loadingLabel.text = @"获取信息失败";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *availableIdentifier = @"AvailableIdentifier";
    static NSString *notAvailableIdentifier = @"NotAvailableIdentifier";
    
    
    UITableViewCell *cell;
    if (_available == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:availableIdentifier];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:notAvailableIdentifier];
    }
    if (cell == nil) {
        float fontSize = 10;
        
        if (_available == 1) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:availableIdentifier];
            UILabel *placeLabel = [[UILabel alloc] init];
            placeLabel.numberOfLines = 0;
            [placeLabel setTag:100];
            placeLabel.font = [UIFont systemFontOfSize:fontSize];
            placeLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:placeLabel];
            
            UILabel *infoLabel = [[UILabel alloc] init];
            infoLabel.numberOfLines = 0;
            [infoLabel setTag:101];
            infoLabel.font = [UIFont systemFontOfSize:fontSize];
            infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:infoLabel];
            
            [cell.contentView addConstraints:[NSLayoutConstraint
                                              constraintsWithVisualFormat:@"H:|-5-[placeLabel(180)]-5-[infoLabel]-5-|"
                                              options:NSLayoutFormatAlignAllCenterY
                                              metrics:nil
                                              views:NSDictionaryOfVariableBindings(placeLabel, infoLabel)]];
            [cell.contentView addConstraint:[NSLayoutConstraint
                                             constraintWithItem:placeLabel attribute:NSLayoutAttributeCenterY
                                             relatedBy:NSLayoutRelationEqual
                                             toItem:cell.contentView attribute:NSLayoutAttributeCenterY
                                             multiplier:1.0f constant:0.0f]];
            [cell.contentView addConstraint:[NSLayoutConstraint
                                             constraintWithItem:placeLabel attribute:NSLayoutAttributeHeight
                                             relatedBy:NSLayoutRelationLessThanOrEqual
                                             toItem:cell.contentView attribute:NSLayoutAttributeHeight
                                             multiplier:1.0f constant:-16.0f]];
            [cell.contentView addConstraint:[NSLayoutConstraint
                                             constraintWithItem:infoLabel attribute:NSLayoutAttributeHeight
                                             relatedBy:NSLayoutRelationLessThanOrEqual
                                             toItem:cell.contentView attribute:NSLayoutAttributeHeight
                                             multiplier:1.0f constant:-16.0f]];
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:notAvailableIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:fontSize];
        }
    }
    
//    if (_available == 1) {
//        UILabel *placeLabel = (UILabel *)[cell viewWithTag:100];
//        placeLabel.text = [self collection][indexPath.row][@"lib_location"];
//        
//        UILabel *infoLabel = (UILabel *)[cell viewWithTag:101];
//        infoLabel.text = [self collection][indexPath.row][@"lib_status"];
//    } else {
//        cell.textLabel.text = [self collection][indexPath.row];
//    }
    
    return cell;
}



@end
