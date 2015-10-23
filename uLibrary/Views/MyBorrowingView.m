//
//  MyBorrowingView.m
//  uLibrary
//
//  Created by 陈颖鹏 on 15/1/17.
//  Copyright (c) 2015年 UniqueStudio. All rights reserved.
//

#import "MyBorrowingView.h"
#import "HomeViewParameterH.h"

@interface MyBorrowingView ()

@end

@implementation MyBorrowingView

- (id)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setUp {
    UIImageView *myBorrowingPic = [[UIImageView alloc] init];
    _myBorrowingPic = myBorrowingPic;
    _myBorrowingPic.contentMode = UIViewContentModeScaleAspectFill;
    _myBorrowingPic.image = [[UIImage imageNamed:@"myborrowing_icon"]
                             imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _myBorrowingPic.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_myBorrowingPic];
    
    UILabel *myBorrowingLabel = [[UILabel alloc] init];
    _myBorrowingLabel = myBorrowingLabel;
    _myBorrowingLabel.font = [UIFont systemFontOfSize:FONT_SIZE_LARGE];
    _myBorrowingLabel.textColor = THEME_GREEN;
    _myBorrowingLabel.text = @"我的借阅";
    _myBorrowingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_myBorrowingLabel];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:|[_myBorrowingPic(32)]-(>=0)-|"
                          options:0
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(_myBorrowingPic)]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-15-[_myBorrowingPic(32)][_myBorrowingLabel]"
                          options:NSLayoutFormatAlignAllCenterY
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(_myBorrowingPic, _myBorrowingLabel)]];
}

@end
