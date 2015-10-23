//
//  DetailsView.h
//  Library
//
//  Created by 陈颖鹏 on 14-10-16.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsView : UIScrollView

@property (strong, nonatomic) NSDictionary *model;

@property (strong, nonatomic) NSDictionary *renewedDic;

- (void)updateLoadingViewAfterFailing;

@end
