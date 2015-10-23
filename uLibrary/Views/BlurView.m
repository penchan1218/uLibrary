//
//  BlurView.m
//  Library
//
//  Created by 陈颖鹏 on 14/11/6.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "BlurView.h"
#import "UIView+Screenshot.h"
#import <Accelerate/Accelerate.h>
#import "UIImage+ImageEffects.h"
#import "UIImage+StackBlur.h"

@implementation BlurView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setBackground:(UIView *)background {
    _background = background;
    UIImage *original_background_image = [_background convertViewToImage];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.image = [original_background_image stackBlur:40];
    [self addSubview:imageView];

    //30  0.2
//    imageView.image = [original_background_image applyBlurWithRadius:30 tintColor:[UIColor colorWithWhite:1.0 alpha:0.2] saturationDeltaFactor:1.8 maskImage:nil];
//    imageView.image = [compressed_background_image applyBlurWithRadius:30 tintColor:[UIColor colorWithWhite:1.0 alpha:0.2] saturationDeltaFactor:1.8 maskImage:nil];
//    imageView.image = [_background convertViewToImage];
    
}



@end
