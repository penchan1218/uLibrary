//
//  ProgressBar.h
//  Library
//
//  Created by 陈颖鹏 on 14/12/3.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressBar : UIView

@property (nonatomic, assign) CGFloat progressValue;

- (void)beginAnimating;

- (void)animatingCompleted;

@end
