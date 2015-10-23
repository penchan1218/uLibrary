//
//  LoginView.h
//  uLibrary
//
//  Created by 陈颖鹏 on 15/1/18.
//  Copyright (c) 2015年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Screenshot.h"
#import "UIImage+ImageEffects.h"
#import "MBProgressHUD.h"

@interface LoginView : UIView <UITextFieldDelegate>

@property (weak, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) UIView *backgroundView;
@property (weak, nonatomic) UIButton *cancelBtn;
@property (weak, nonatomic) UITextField *nameTf;
@property (weak, nonatomic) UITextField *codeTf;
@property (weak, nonatomic) UIButton *helpBtn;
@property (weak, nonatomic) UIButton *loginBtn;
@property (weak, nonatomic) MBProgressHUD *loginHUD;

- (void)showWithCompletionHandler:(void (^)(BOOL finished))completionHandler;
- (void)hideWithCompletionHandler:(void (^)(BOOL finished))completionHandler;

@end
