//
//  ProgressBar.m
//  Library
//
//  Created by 陈颖鹏 on 14/12/3.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "ProgressBar.h"

@implementation ProgressBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromRGBA(76, 220, 99, 1.0);
    }
    return self;
}

- (void)beginAnimating {
    self.progressValue = 0.0f;
}

- (void)animatingCompleted {
    self.progressValue = 1.0f;
}

- (void)setProgressValue:(CGFloat)progressValue {
    _progressValue = progressValue;
    [UIView animateWithDuration:0.10f animations:^{
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, [[UIScreen mainScreen] bounds].size.width*_progressValue, self.frame.size.height);
    } completion:^(BOOL finished) {
        if (_progressValue == 1.0f) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5*NSEC_PER_SEC),
                           dispatch_get_main_queue(), ^{
                               [self removeFromSuperview];
                           });
        } else if (_progressValue < 0.8f) {
            if (_progressValue < 0.3f) {
                self.progressValue += 0.02;
            } else if (_progressValue < 0.5f) {
                self.progressValue += 0.01;
            } else {
                self.progressValue += 0.005;
            }
        }
    }];
}

@end
