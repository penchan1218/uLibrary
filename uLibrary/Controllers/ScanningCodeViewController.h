//
//  ScanningCodeViewController.h
//  uLibrary
//
//  Created by 陈颖鹏 on 15/3/15.
//  Copyright (c) 2015年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ScanningCodeViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate> {
    float lineWidth;
    float borderWidth;
    int num;
    BOOL upOrDown;
    NSTimer *timer;
}

@property (strong, nonatomic) AVCaptureDevice               *device;
@property (strong ,nonatomic) AVCaptureDeviceInput          *input;
@property (strong, nonatomic) AVCaptureMetadataOutput       *output;
@property (strong, nonatomic) AVCaptureSession              *session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer    *previewLayer;

@property (weak, nonatomic) UIImageView                     *border;
@property (weak, nonatomic) UIImageView                     *line;


@end
