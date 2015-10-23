//
//  LoginHelpViewController.m
//  uLibrary
//
//  Created by 陈颖鹏 on 15/3/27.
//  Copyright (c) 2015年 UniqueStudio. All rights reserved.
//

#import "LoginHelpViewController.h"

@implementation LoginHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *array = [NSArray arrayWithObjects:_firstLabel, _first_firstLabel, _first_secondLabel, _secondLabel, _second_firstLabel, _second_secondLabel, _second_thirdLabel, nil];
    
    UIFont *font_4s_5_large     = [UIFont systemFontOfSize:17.0f];
    UIFont *font_4s_5_little    = [UIFont systemFontOfSize:14.0f];
    
    UIFont *font_6_large        = [UIFont systemFontOfSize:20.0f];
    UIFont *font_6_little       = [UIFont systemFontOfSize:16.0f];
    
    UIFont *font_6p_large       = [UIFont systemFontOfSize:23.0f];
    UIFont *font_6p_little      = [UIFont systemFontOfSize:18.0f];
    
    UIFont *font_large;
    UIFont *font_little;
    
    if (IPHONE6_SCREEN) {
        font_large = font_6_large;
        font_little = font_6_little;
    } else if (IPHONE6P_SCREEN) {
        font_large = font_6p_large;
        font_little = font_6p_little;
    } else {
        font_large = font_4s_5_large;
        font_little = font_4s_5_little;
    }
    
    _titleLabel.font = font_large;
    for (UILabel *label in array) {
        label.font = font_little;
    }
    
}

@end
