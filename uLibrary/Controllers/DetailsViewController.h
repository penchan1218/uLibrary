//
//  DetailsViewController.h
//  Library
//
//  Created by 陈颖鹏 on 14-10-16.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailsViewCollectBookDelegate.h"

@interface DetailsViewController : UIViewController

@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, copy) NSIndexPath *indexpath;

@property (weak, nonatomic) id<DetailsViewCollectBookDelegate> delegate;

- (id)initWithIdentifier:(NSString *)identifier;

@end
