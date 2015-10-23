//
//  RightDrawerDelegate.h
//  Library
//
//  Created by 陈颖鹏 on 14/11/15.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RightDrawerDelegate <NSObject>

- (void)rightDrawerDidSelectTheBookWithIdentifier:(NSString *)identifier;

@end
