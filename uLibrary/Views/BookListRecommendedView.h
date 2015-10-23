//
//  BookListRecommendedView.h
//  uLibrary
//
//  Created by 陈颖鹏 on 14/12/13.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookListRecommendedView : UIView

- (void)setUp;

- (void)setBookListImageWithURL:(NSString *)urlStr tag:(NSInteger)tag;

- (void)setBookListName:(NSString *)name tag:(NSInteger)tag;

@end
