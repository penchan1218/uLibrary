//
//  BriefTableViewCell.h
//  Library
//
//  Created by 陈颖鹏 on 14-10-11.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BriefTableViewCell : UITableViewCell

@property (weak, nonatomic) UIImageView *cover_imageView;
@property (weak, nonatomic) UIImageView *collect_mark_imageView;
@property (weak, nonatomic) UIView *infoView;

@property (nonatomic, copy) NSIndexPath *indexpath;

@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) UILabel *authorLabel;
@property (weak, nonatomic) UILabel *pressLabel;

@end
