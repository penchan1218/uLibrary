//
//  LibraryCollectionView.m
//  uLibrary
//
//  Created by 陈颖鹏 on 14/12/13.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "LibraryCollectionView.h"
#import "HomeViewParameterH.h"

@interface LibraryCollectionView ()

@property (strong, nonatomic) NSMutableArray *unfoldImageViewMutArr;
@property (strong, nonatomic) NSMutableArray *placeLabelMutArr;
@property (strong, nonatomic) NSMutableArray *detailsMutArr;

@property (strong, nonatomic) NSMutableArray *briefSeparatorMutArr;
@property (strong, nonatomic) NSMutableArray *detailSeparatorMutArr;

@end

@implementation LibraryCollectionView

- (void)setUp {
    
    _unfoldImageViewMutArr = [NSMutableArray array];
    _placeLabelMutArr = [NSMutableArray array];
    _detailsMutArr = [NSMutableArray array];
    
    _briefSeparatorMutArr = [NSMutableArray array];
    _detailSeparatorMutArr = [NSMutableArray array];
    
    [_detailsMutArr addObject:@"一层 综合阅览室、借还书处、办证处\n二层 TP TQ TS TU TV U V X Z\n三层 N O P T TB TD TE TF TG TH TJ TK TL TM TN\n四层 G H I J K\n五层 A B C D E F\n六层 外文图书阅览室"];
    [_detailsMutArr addObject:@"一层 旧书报刊密集库\n二层 TP TU N O P TB TD TE TF TG TH TJ TK TL TM TS TV U V X Z\n三层 A B C D E F G H\n四层 中外文过刊阅览室\n五层 I K"];
    [_detailsMutArr addObject:@"二层中厅 流通借还处\n一层 F H J Q R S\n二层 I\n三层 A B C D E G K TN TQ TS TU TV\n四层 TP U V X Z\n五层 N O P T TB TD TE TF TG TH TJ TK TL TM TU"];
    [_detailsMutArr addObject:@"二层北 H K G\n二层南 A B C D F E\n三层南 T.TB-TV(TP除外) U V X Z\n四层南 N O P Q R S\n四层北 TP"];
    
    UIImageView *libraryCollectionImageView = [[UIImageView alloc] init];
    libraryCollectionImageView.clipsToBounds = YES;
    libraryCollectionImageView.contentMode = UIViewContentModeScaleAspectFill;
    libraryCollectionImageView.image = [UIImage imageNamed:@"booklocation_icon"];
    libraryCollectionImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:libraryCollectionImageView];
    
    UILabel *libraryCollectionLabel = [[UILabel alloc] init];
    libraryCollectionLabel.textColor = UIColorFromRGBA(76, 220, 99, 1.0);
    libraryCollectionLabel.font = [UIFont systemFontOfSize:FONT_SIZE_LARGE];
    libraryCollectionLabel.text = @"馆藏地图";
    libraryCollectionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:libraryCollectionLabel];
    
    for (NSInteger i = 0; i < 8; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.userInteractionEnabled = YES;
        label.backgroundColor = [UIColor whiteColor];
        label.tag = i;
        switch (i) {
            case 0:
                label.text = @"主校区图书馆图书借阅室（B区）";
                break;
            case 2:
                label.text = @"主校区图书馆逸夫馆图书阅览室（C区）";
                break;
            case 4:
                label.text = @"东校区图书馆流动书库";
                break;
            case 6:
                label.text = @"东校区图书馆阅览室";
                break;
            default:
                break;
        }
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:label];
        [_placeLabelMutArr addObject:label];
        
        if (i%2 == 0) {
            label.font = [UIFont systemFontOfSize:FONT_SIZE_MEDIUM];
            label.textColor = [UIColor blackColor];
            UITapGestureRecognizer *tapOnLabelGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnLabel:)];
            [label addGestureRecognizer:tapOnLabelGesture];
            
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.image = [UIImage imageNamed:@"unfold_mark"];
            imageView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:imageView];
            [_unfoldImageViewMutArr addObject:imageView];
            
            [imageView addConstraints:[NSLayoutConstraint
                                       constraintsWithVisualFormat:@"V:[imageView(24)]"
                                       options:0
                                       metrics:nil
                                       views:NSDictionaryOfVariableBindings(imageView)]];
            [self addConstraints:[NSLayoutConstraint
                                  constraintsWithVisualFormat:@"H:[imageView(24)]-22-|"
                                  options:0
                                  metrics:nil
                                  views:NSDictionaryOfVariableBindings(imageView)]];
            [self addConstraint:[NSLayoutConstraint
                                 constraintWithItem:imageView attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:label attribute:NSLayoutAttributeCenterY
                                 multiplier:1.0f constant:0.0f]];
        } else {
            label.font = [UIFont systemFontOfSize:FONT_SIZE_LITTLE];
            label.textColor = UIColorFromRGBA(122, 121, 123, 1.0);
            label.numberOfLines = 0;
        }
    }
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-15-[libraryCollectionImageView(32)][libraryCollectionLabel]"
                          options:NSLayoutFormatAlignAllCenterY
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(libraryCollectionImageView, libraryCollectionLabel)]];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:|[libraryCollectionImageView(32)]"
                          options:0
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(libraryCollectionImageView)]];
    
    float widthBetweenLabels = IPHONE6_SCREEN||IPHONE6P_SCREEN? 20: 15;
    
    UILabel *firstLabel = _placeLabelMutArr[0];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-20-[firstLabel]"
                          options:0
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(firstLabel)]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:[libraryCollectionLabel]-(widthBetweenLabels)-[firstLabel]"
                          options:0
                          metrics:@{@"widthBetweenLabels": @(widthBetweenLabels)}
                          views:NSDictionaryOfVariableBindings(libraryCollectionLabel, firstLabel)]];
    
    UILabel *secondLabel = _placeLabelMutArr[1];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-46-[secondLabel]-22-|"
                          options:0
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(secondLabel)]];
    
    for (NSInteger i = 1; i < _placeLabelMutArr.count; i++) {
        UILabel *formmerLabel = _placeLabelMutArr[i-1];
        UILabel *latterLabel = _placeLabelMutArr[i];
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:[formmerLabel]-(widthBetweenLabels)-[latterLabel]"
                              options:NSLayoutFormatAlignAllRight
                              metrics:@{@"widthBetweenLabels": @(widthBetweenLabels)}
                              views:NSDictionaryOfVariableBindings(formmerLabel, latterLabel)]];
    }
    
    for (NSInteger i = 2; i < _placeLabelMutArr.count; i+=2) {
        UILabel *formmerLabel = _placeLabelMutArr[i-2];
        UILabel *latterLabel = _placeLabelMutArr[i];
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:formmerLabel attribute:NSLayoutAttributeLeft
                             relatedBy:NSLayoutRelationEqual
                             toItem:latterLabel attribute:NSLayoutAttributeLeft
                             multiplier:1.0f constant:0.0f]];
    }
    
    for (NSInteger i = 3; i < _placeLabelMutArr.count; i+=2) {
        UILabel *formmerLabel = _placeLabelMutArr[i-2];
        UILabel *latterLabel = _placeLabelMutArr[i];
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:formmerLabel attribute:NSLayoutAttributeLeft
                             relatedBy:NSLayoutRelationEqual
                             toItem:latterLabel attribute:NSLayoutAttributeLeft
                             multiplier:1.0f constant:0.0f]];
    }
    
    for (NSInteger i = 1; i < _placeLabelMutArr.count; i+=2) {
        UILabel *briefLabel = _placeLabelMutArr[i-1];
        UILabel *detailLabel = _placeLabelMutArr[i];
        UIView *frontView = [[UIView alloc] init];
        frontView.backgroundColor = UIColorFromRGBA(206, 206, 206, 1.0);
        frontView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:frontView];
        
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"H:[frontView(2.5)]-4-[detailLabel]"
                              options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
                              metrics:nil
                              views:NSDictionaryOfVariableBindings(frontView, detailLabel)]];
        
        UIView *briefSeparator = [[UIView alloc] init];
        briefSeparator.backgroundColor = UIColorFromRGBA(206, 206, 206, 1.0);
        briefSeparator.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:briefSeparator];
        [_briefSeparatorMutArr addObject:briefSeparator];
        
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:[briefLabel]-(widthBetweenLabels)-[briefSeparator(0.5)]"
                              options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                              metrics:@{@"widthBetweenLabels": @(widthBetweenLabels)}
                              views:NSDictionaryOfVariableBindings(briefLabel, briefSeparator)]];
        
        UIView *detailSeparator = [[UIView alloc] init];
        detailSeparator.backgroundColor = UIColorFromRGBA(206, 206, 206, 1.0);
        detailSeparator.alpha = 0.0f;
        detailSeparator.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:detailSeparator];
        [_detailSeparatorMutArr addObject:detailSeparator];
        
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:[detailLabel]-(widthBetweenLabels)-[detailSeparator(0.5)]"
                              options:0
                              metrics:@{@"widthBetweenLabels": @(widthBetweenLabels/2)}
                              views:NSDictionaryOfVariableBindings(detailLabel, detailSeparator)]];
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:briefLabel attribute:NSLayoutAttributeLeft
                             relatedBy:NSLayoutRelationEqual
                             toItem:detailSeparator attribute:NSLayoutAttributeLeft
                            multiplier:1.0f constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:briefLabel attribute:NSLayoutAttributeRight
                             relatedBy:NSLayoutRelationEqual
                             toItem:detailSeparator attribute:NSLayoutAttributeRight
                             multiplier:1.0f constant:0.0f]];
        
    }
    
    UIView *lastSeparator = _detailSeparatorMutArr[_detailSeparatorMutArr.count-1];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:[lastSeparator]|"
                          options:0
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(lastSeparator)]];
}

- (void)tapOnLabel:(UITapGestureRecognizer *)gesture {
    UILabel *tapLabel = (UILabel *)(gesture.view);
    UILabel *detailsLabel = _placeLabelMutArr[tapLabel.tag+1];
    UIView *briefSeparator = _briefSeparatorMutArr[tapLabel.tag/2];
    UIView *detailSeparator = _detailSeparatorMutArr[tapLabel.tag/2];
    if (detailsLabel.text == nil) {
        briefSeparator.alpha = 0.0f;
        detailsLabel.alpha = 0.0f;
        [detailsLabel setText:_detailsMutArr[tapLabel.tag/2]];
        [UIView animateWithDuration:0.2f animations:^{
            detailsLabel.alpha = 1.0f;
        } completion:^(BOOL finished) {
            detailSeparator.alpha = 1.0f;
        }];
        UIImageView *unfoldImageView = [_unfoldImageViewMutArr objectAtIndex:tapLabel.tag/2];
        [UIView animateWithDuration:0.1 animations:^{
            unfoldImageView.transform = CGAffineTransformMakeRotation(M_PI);
        }];
    } else {
        UIImageView *unfoldImageView = [_unfoldImageViewMutArr objectAtIndex:tapLabel.tag/2];
        [UIView animateWithDuration:0.1 animations:^{
            unfoldImageView.transform = CGAffineTransformIdentity;
        }];
        detailSeparator.alpha = 0.0f;
        [detailsLabel setText:nil];
        [UIView animateWithDuration:0.2f animations:^{
        } completion:^(BOOL finished) {
            briefSeparator.alpha = 1.0f;
        }];
    }
}

@end
