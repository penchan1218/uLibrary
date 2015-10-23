//
//  DetailsViewCollectBookDelegate.h
//  uLibrary
//
//  Created by 陈颖鹏 on 14/12/6.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DetailsViewCollectBookDelegate <NSObject>

- (void)didCollectBookInDetailsViewAtIndexPath:(NSIndexPath *)indexpath;

- (void)didRemoveBookInDetailsView:(NSIndexPath *)indexpath;

@end
