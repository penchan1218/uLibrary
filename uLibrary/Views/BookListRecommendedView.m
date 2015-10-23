//
//  BookListRecommendedView.m
//  uLibrary
//
//  Created by 陈颖鹏 on 14/12/13.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "BookListRecommendedView.h"
#import "NWManager.h"
#import "HomeViewParameterH.h"

@interface BookListRecommendedView ()

@property (strong, nonatomic) NSMutableArray *bookListImageViewMutArr;
@property (strong, nonatomic) NSMutableArray *bookListLabelMutArr;

@end

@implementation BookListRecommendedView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setUp {
    
    _bookListImageViewMutArr = [NSMutableArray array];
    _bookListLabelMutArr = [NSMutableArray array];
    
    
    UIImageView *recommendImageView = [[UIImageView alloc] init];
    recommendImageView.clipsToBounds = YES;
    recommendImageView.contentMode = UIViewContentModeScaleAspectFill;
    recommendImageView.image = [UIImage imageNamed:@"booklist_icon"];
    recommendImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:recommendImageView];
    
    UILabel *recommendLabel = [[UILabel alloc] init];
    recommendLabel.textColor = THEME_GREEN;
    recommendLabel.font = [UIFont systemFontOfSize:FONT_SIZE_LARGE];
    recommendLabel.text = @"书单推荐";
    recommendLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:recommendLabel];
    
    for (NSInteger i = 0; i < 4; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.userInteractionEnabled = YES;
        imageView.tag = i;
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.borderWidth = 1.0f;
        imageView.layer.borderColor = UIColorFromRGBA(245, 245, 245, 1.0).CGColor;
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:imageView];
        [_bookListImageViewMutArr addObject:imageView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnImageView:)];
        [imageView addGestureRecognizer:tapGesture];
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:FONT_SIZE_MEDIUM];
        label.text = [NSString stringWithFormat:@"书单%ld", (unsigned long)(i+1)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = UIColorFromRGBA(51, 51, 51, 1.0);
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:label];
        [_bookListLabelMutArr addObject:label];
    }
    
    
    UIImageView *firstImageView = _bookListImageViewMutArr[0];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-15-[recommendImageView(32)][recommendLabel]"
                          options:NSLayoutFormatAlignAllCenterY
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(recommendImageView, recommendLabel)]];
    [recommendImageView addConstraint:[NSLayoutConstraint
                         constraintWithItem:recommendImageView attribute:NSLayoutAttributeWidth
                         relatedBy:NSLayoutRelationEqual
                         toItem:recommendImageView attribute:NSLayoutAttributeHeight
                         multiplier:1.0f constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:recommendImageView attribute:NSLayoutAttributeTop
                         relatedBy:NSLayoutRelationEqual
                         toItem:self attribute:NSLayoutAttributeTop
                         multiplier:1.0f constant:0.0f]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:[recommendLabel]-(height)-[firstImageView]"
                          options:0
                          metrics:@{@"height": @(IPHONE6_SCREEN||IPHONE6P_SCREEN? 20: 15)}
                          views:NSDictionaryOfVariableBindings(recommendLabel, firstImageView)]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-20-[firstImageView]"
                          options:0
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(firstImageView)]];
    
    [firstImageView addConstraint:[NSLayoutConstraint
                                   constraintWithItem:firstImageView attribute:NSLayoutAttributeHeight
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:firstImageView attribute:NSLayoutAttributeWidth
                                   multiplier:1.5f constant:0.0f]];
    
    for (NSInteger i = 1; i < _bookListImageViewMutArr.count; i++) {
        UIImageView *formmerImageView = _bookListImageViewMutArr[i-1];
        UIImageView *latterImageView = _bookListImageViewMutArr[i];
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"H:[formmerImageView]-(width)-[latterImageView]"
                              options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
                              metrics:@{@"width": @(40/3)}
                              views:NSDictionaryOfVariableBindings(formmerImageView, latterImageView)]];
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:formmerImageView attribute:NSLayoutAttributeWidth
                             relatedBy:NSLayoutRelationEqual
                             toItem:latterImageView attribute:NSLayoutAttributeWidth
                             multiplier:1.0f constant:0.0f]];
    }
    
    UIImageView *lastImageView = _bookListImageViewMutArr[_bookListImageViewMutArr.count-1];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:[lastImageView]-20-|"
                          options:0
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(lastImageView)]];
    
    for (NSInteger i = 0; i < _bookListImageViewMutArr.count; i++) {
        UIImageView *imageView = _bookListImageViewMutArr[i];
        UILabel *label = _bookListLabelMutArr[i];
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:[imageView]-5-[label]|"
                              options:NSLayoutFormatAlignAllCenterX
                              metrics:nil
                              views:NSDictionaryOfVariableBindings(imageView, label)]];
    }
}

- (void)tapOnImageView:(UITapGestureRecognizer *)gesture {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TapOnBookListRecommendedImageView" object:nil userInfo:@{@"name": [NSString stringWithFormat:@"bookrec0%ld", (unsigned long)(gesture.view.tag+1)]}];
}

- (void)setBookListImageWithURL:(NSString *)urlStr tag:(NSInteger)tag {
    UIImageView *imageView = _bookListImageViewMutArr[tag];
    [imageView setImageWithURL:[NSURL URLWithString:urlStr]];
}

- (void)setBookListName:(NSString *)name tag:(NSInteger)tag {
    UILabel *label = _bookListLabelMutArr[tag];
    label.text = name;
}

@end
