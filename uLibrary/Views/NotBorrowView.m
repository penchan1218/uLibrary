//
//  NotBorrowView.m
//  uLibrary
//
//  Created by 陈颖鹏 on 15/3/3.
//  Copyright (c) 2015年 UniqueStudio. All rights reserved.
//

#import "NotBorrowView.h"
#import "HomeViewParameterH.h"

@implementation NotBorrowView

- (void)setUp {
    [super setUp];
    
    UILabel *requestForLoggingInLabel = [[UILabel alloc] init];
    _requestForLoggingInLabel = requestForLoggingInLabel;
    _requestForLoggingInLabel.font = [UIFont systemFontOfSize:FONT_SIZE_MEDIUM];
    _requestForLoggingInLabel.textAlignment = NSTextAlignmentLeft;
    _requestForLoggingInLabel.text = @"未登录，无法查看借阅信息";
    _requestForLoggingInLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_requestForLoggingInLabel];
    
    UIButton *loginBtn = [[UIButton alloc] init];
    _loginBtn = loginBtn;
    _loginBtn.layer.cornerRadius = 5.0f;
    _loginBtn.layer.borderWidth = 1.0f;
    _loginBtn.layer.borderColor = THEME_GREEN.CGColor;
    _loginBtn.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_LITTLE];
    [_loginBtn setTitleColor:THEME_GREEN forState:UIControlStateNormal];
    [_loginBtn setTitle:@"  立即登录  " forState:UIControlStateNormal];
    [_loginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    _loginBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_loginBtn];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:[myBorrowingLabel]-15-[_requestForLoggingInLabel]|"
                          options:0
                          metrics:nil
                          views:@{@"myBorrowingLabel": self.myBorrowingLabel,
                                  @"_requestForLoggingInLabel": _requestForLoggingInLabel}]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-20-[_requestForLoggingInLabel]-(>=0)-[_loginBtn]-20-|"
                          options: NSLayoutFormatAlignAllCenterY
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(_requestForLoggingInLabel, _loginBtn)]];
//    [self addConstraints:[NSLayoutConstraint
//                          constraintsWithVisualFormat:@"V:[_loginBtn]"
//                          options:0
//                          metrics:nil
//                          views:NSDictionaryOfVariableBindings(_loginBtn)]];
}

- (void)login {
    //发送消息让controller控制登录
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestForLoggingIn" object:nil];
}

@end
