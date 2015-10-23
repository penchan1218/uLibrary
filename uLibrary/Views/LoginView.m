//
//  LoginView.m
//  uLibrary
//
//  Created by 陈颖鹏 on 15/1/18.
//  Copyright (c) 2015年 UniqueStudio. All rights reserved.
//

#import "LoginView.h"
#import <QuartzCore/QuartzCore.h>
#import "WSManager.h"
#import "HomeViewParameterH.h"

@implementation LoginView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.alpha = 0.0f;
        self.backgroundColor = [UIColor whiteColor];
        
        //监听信息完整并登录后的登录状态
        [[NSNotificationCenter defaultCenter] addObserverForName:@"WaitingForLoggingIn"
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          NSString *status = [note userInfo][@"status"];
                                                          if ([status isEqualToString:@"success"]) {
                                                              //登录成功
                                                              _loginHUD.mode = MBProgressHUDModeText;
                                                              _loginHUD.labelText = @"登录成功";
                                                              [_loginHUD hide:YES afterDelay:1.0f];
                                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"DidLogin" object:nil];
                                                              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                  [self hideWithCompletionHandler:nil];
                                                              });
                                                          } else if ([status isEqualToString:@"fail"]) {
                                                              //登录失败
                                                              _loginHUD.mode = MBProgressHUDModeText;
                                                              _loginHUD.labelText = @"请检查姓名和卡号是否正确";
                                                              [_loginHUD hide:YES afterDelay:1.0f];
                                                          }
                                                      }];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
//    float fontSize = 14.0f;
    UIColor *labelFontColor = UIColorFromRGBA(151, 151, 151, 1.0);
    UIColor *tfTextColor = UIColorFromRGBA(51, 51, 51, 1.0);
    UIColor *tfBackgroundColor = UIColorFromRGBA(229, 229, 229, 1.0);
    
    UIImageView *imageView = [[UIImageView alloc] init];
    _imageView = imageView;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.userInteractionEnabled = YES;
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_imageView];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|[_imageView]|"
                          options:0 metrics:nil
                          views:NSDictionaryOfVariableBindings(_imageView)]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:|[_imageView]|"
                          options:0 metrics:nil
                          views:NSDictionaryOfVariableBindings(_imageView)]];
    
    UIView *backgroundView = [[UIView alloc] init];
    _backgroundView = backgroundView;
    _backgroundView.backgroundColor = [UIColor whiteColor];
    _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [_imageView addSubview:_backgroundView];
    
    CALayer *layer = backgroundView.layer;
    layer.shadowOffset = CGSizeMake(1, 0.0);
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowRadius = 4.0f;
    layer.shadowOpacity = 0.6f;
    layer.masksToBounds = NO;
    
    float screen_width = [[UIScreen mainScreen] bounds].size.width;
    float backgroundViewHeight = 0.80625*screen_width*0.686;
    
    [_imageView addConstraints:[NSLayoutConstraint
                                constraintsWithVisualFormat:@"H:|-31-[_backgroundView]-31-|"
                                options:0 metrics:nil
                                views:NSDictionaryOfVariableBindings(_backgroundView)]];
    [_imageView addConstraints:[NSLayoutConstraint
                                constraintsWithVisualFormat:@"V:|-(space)-[_backgroundView(height)]"
                                options:0
                                metrics:@{@"space": @(IPHONE4S_SCREEN? 20: 44.5),
                                          @"height": @(backgroundViewHeight)}
                                views:NSDictionaryOfVariableBindings(_backgroundView)]];
    
    
    UIButton *cancelBtn = [[UIButton alloc] init];
    _cancelBtn = cancelBtn;
    [_cancelBtn setImage:[UIImage imageNamed:@"login_exit"] forState:UIControlStateNormal];
    [_cancelBtn setImage:[UIImage imageNamed:@"login_exit_pressed"] forState:UIControlStateHighlighted];
    [_cancelBtn addTarget:self action:@selector(cancelBtnDidClicked) forControlEvents:UIControlEventTouchUpInside];
    _cancelBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_backgroundView addSubview:_cancelBtn];
    
    [_backgroundView addConstraints:[NSLayoutConstraint
                                     constraintsWithVisualFormat:@"V:|-13-[_cancelBtn(16)]"
                                     options:0 metrics:nil
                                     views:NSDictionaryOfVariableBindings(_cancelBtn)]];
    [_backgroundView addConstraints:[NSLayoutConstraint
                                     constraintsWithVisualFormat:@"H:[_cancelBtn(16)]-13-|"
                                     options:0 metrics:nil
                                     views:NSDictionaryOfVariableBindings(_cancelBtn)]];
    
    float font_size = 16.0f;
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = @"姓名";
    nameLabel.font = [UIFont systemFontOfSize:font_size];
    nameLabel.textColor = labelFontColor;
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_backgroundView addSubview:nameLabel];
    
    UITextField *nameTf = [[UITextField alloc] init];
    _nameTf = nameTf;
    _nameTf.text = @"  ";
    _nameTf.clearButtonMode = UITextFieldViewModeWhileEditing;
    _nameTf.delegate = self;
    _nameTf.font = [UIFont systemFontOfSize:font_size];
    _nameTf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _nameTf.textColor = tfTextColor;
    _nameTf.backgroundColor = tfBackgroundColor;
    _nameTf.translatesAutoresizingMaskIntoConstraints = NO;
    [_backgroundView addSubview:_nameTf];
    
    UILabel *codeLabel = [[UILabel alloc] init];
    codeLabel.text = @"卡号";
    codeLabel.font = [UIFont systemFontOfSize:font_size];
    codeLabel.textColor = labelFontColor;
    codeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_backgroundView addSubview:codeLabel];
    
    UITextField *codeTf = [[UITextField alloc] init];
    _codeTf = codeTf;
    _codeTf.text = @"  ";
    _codeTf.clearButtonMode = UITextFieldViewModeWhileEditing;
    _codeTf.delegate = self;
    _codeTf.font = [UIFont systemFontOfSize:font_size];
    _cancelBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _codeTf.textColor = tfTextColor;
    _codeTf.backgroundColor = tfBackgroundColor;
    _codeTf.translatesAutoresizingMaskIntoConstraints = NO;
    [_backgroundView addSubview:_codeTf];
    
    [_backgroundView addConstraints:[NSLayoutConstraint
                                     constraintsWithVisualFormat:@"H:|-22-[nameLabel]"
                                     options:0 metrics:nil
                                     views:NSDictionaryOfVariableBindings(nameLabel)]];
    [_backgroundView addConstraint:[NSLayoutConstraint
                                    constraintWithItem:nameLabel attribute:NSLayoutAttributeLeft
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:codeLabel attribute:NSLayoutAttributeLeft
                                    multiplier:1.0f constant:0.0f]];
    [_backgroundView addConstraints:[NSLayoutConstraint
                                     constraintsWithVisualFormat:@"H:|-64-[_nameTf]-26-|"
                                     options:0 metrics:nil
                                     views:NSDictionaryOfVariableBindings(_nameTf)]];
    
    [_backgroundView addConstraints:[NSLayoutConstraint
                                     constraintsWithVisualFormat:@"V:[_nameTf]-(space)-[_codeTf]"
                                     options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                     metrics:@{@"space": @(0.1*backgroundViewHeight)}
                                     views:NSDictionaryOfVariableBindings(_nameTf, _codeTf)]];
    [_backgroundView addConstraint:[NSLayoutConstraint
                                    constraintWithItem:_codeTf attribute:NSLayoutAttributeTop
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:_backgroundView attribute:NSLayoutAttributeCenterY
                                    multiplier:1.0f constant:0.0f]];
    [_backgroundView addConstraint:[NSLayoutConstraint
                                    constraintWithItem:_nameTf attribute:NSLayoutAttributeCenterY
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:nameLabel attribute:NSLayoutAttributeCenterY
                                    multiplier:1.0f constant:0.0f]];
    [_backgroundView addConstraint:[NSLayoutConstraint
                                    constraintWithItem:_codeTf attribute:NSLayoutAttributeCenterY
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:codeLabel attribute:NSLayoutAttributeCenterY
                                    multiplier:1.0f constant:0.0f]];
    
    _nameTf.layer.cornerRadius = 10.0f;
    _codeTf.layer.cornerRadius = 10.0f;
    
    UIButton *loginBtn = [[UIButton alloc] init];
    _loginBtn = loginBtn;
    [_loginBtn setTitleColor:UIColorFromRGBA(76, 221, 99, 1.0) forState:UIControlStateNormal];
    _loginBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [_loginBtn setTitle:@"登 录" forState:UIControlStateNormal];
    [_loginBtn addTarget:self action:@selector(loginBtnDidClicked) forControlEvents:UIControlEventTouchUpInside];
    _loginBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_backgroundView addSubview:_loginBtn];
    
    UIButton *helpBtn = [[UIButton alloc] init];
    _helpBtn = helpBtn;
    [_helpBtn setTitleColor:UIColorFromRGBA(204, 204, 204, 1.0) forState:UIControlStateNormal];
    _helpBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [_helpBtn setTitle:@"帮 助" forState:UIControlStateNormal];
    [_helpBtn addTarget:self action:@selector(helpBtnDidClicked) forControlEvents:UIControlEventTouchUpInside];
    _helpBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_backgroundView addSubview:_helpBtn];
    
    float padding = 50;
    
//    [_backgroundView addConstraint:[NSLayoutConstraint
//                                    constraintWithItem:_loginBtn attribute:NSLayoutAttributeCenterX
//                                    relatedBy:NSLayoutRelationEqual
//                                    toItem:_backgroundView attribute:NSLayoutAttributeCenterX
//                                    multiplier:1.0f constant:distanceBetweenTwoBtns/2]];
    [_backgroundView addConstraints:[NSLayoutConstraint
                                     constraintsWithVisualFormat:@"V:[_loginBtn]-23-|"
                                     options:0 metrics:nil
                                     views:NSDictionaryOfVariableBindings(_loginBtn)]];
    [_backgroundView addConstraints:[NSLayoutConstraint
                                    constraintsWithVisualFormat:@"H:|-(padding)-[_helpBtn]-(>=0)-[_loginBtn]-(padding)-|"
                                    options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
                                    metrics:@{@"padding": @(padding)}
                                    views:NSDictionaryOfVariableBindings(_helpBtn, _loginBtn)]];
}

- (void)cancelBtnDidClicked {
    //登录界面的取消按钮被点击
    [self hideWithCompletionHandler:nil];
}

- (void)helpBtnDidClicked {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowLoginHelpView" object:nil];
}

- (void)loginBtnDidClicked {
    //登录界面的登录按钮被点击
    [_nameTf resignFirstResponder];
    [_codeTf resignFirstResponder];
    if (_nameTf.text.length > 2 && _codeTf.text.length > 2) {
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self];
        [self addSubview:HUD];
        HUD.labelText = @"正在登录";
        [HUD show:YES];
        _loginHUD = HUD;
        
        NSString *name = [_nameTf.text substringFromIndex:1];
        NSString *code = [_codeTf.text substringFromIndex:1];
        [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"user_name"];
        [[NSUserDefaults standardUserDefaults] setObject:code forKey:@"user_code"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[WSManager sharedManager] connect];
        
    } else {
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self];
        [self addSubview:HUD];
        HUD.mode = MBProgressHUDModeText;
        HUD.labelText = @"信息不全";
        [HUD show:YES];
        [HUD hide:YES afterDelay:1.0f];
    }
}

- (void)showWithCompletionHandler:(void (^)(BOOL finished))completionHandler {
    UIImage *image = [[self.superview convertViewToImage] applyBlurWithRadius:8 tintColor:[UIColor colorWithWhite:0.5 alpha:0.3] saturationDeltaFactor:1.8 maskImage:nil];
    _imageView.image = image;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if (completionHandler) {
            completionHandler(YES);
        }
        [_nameTf becomeFirstResponder];
    }];
}

- (void)hideWithCompletionHandler:(void (^)(BOOL finished))completionHandler {
    [_nameTf resignFirstResponder];
    [_codeTf resignFirstResponder];
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (completionHandler) {
            completionHandler(YES);
        }
        [self removeFromSuperview];
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (range.location <= 1) {
        return NO;
    }
    if ([string isEqualToString:@"\n"]) {
        if ([_nameTf isFirstResponder]) {
            [_codeTf becomeFirstResponder];
        } else if ([_codeTf isFirstResponder]) {
            [self loginBtnDidClicked];
        }
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    textField.text = @"  ";
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([_nameTf isFirstResponder]) {
        [_nameTf resignFirstResponder];
    }
    if ([_codeTf isFirstResponder]) {
        [_codeTf resignFirstResponder];
    }
}

@end
