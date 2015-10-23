//
//  ScanningCodeViewController.m
//  uLibrary
//
//  Created by 陈颖鹏 on 15/3/15.
//  Copyright (c) 2015年 UniqueStudio. All rights reserved.
//

#import "ScanningCodeViewController.h"

@interface ScanningCodeViewController ()

@end

@implementation ScanningCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColorFromRGBA(48, 47, 53, 1.0);
    
    UIImageView *borderImageView = [[UIImageView alloc] init];
    borderImageView.backgroundColor = [UIColor clearColor];
//    [borderImageView setImage:[UIImage imageNamed:@"pick_bg"]];
    borderImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:borderImageView];
    _border = borderImageView;
    
    UIButton *backBtn = [[UIButton alloc] init];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:20.0];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn setTitle:@"取消" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    backBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:backBtn];
    
    upOrDown = NO;
    num = 0;
    borderWidth = 300.0/320*[[UIScreen mainScreen] bounds].size.width;
    lineWidth = 220.0f/320*[[UIScreen mainScreen] bounds].size.width;
    
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.view attribute:NSLayoutAttributeCenterY
                              relatedBy:NSLayoutRelationEqual
                              toItem:_border attribute:NSLayoutAttributeCenterY
                              multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.view attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:_border attribute:NSLayoutAttributeCenterX
                              multiplier:1.0f constant:0.0f]];
    [_border addConstraint:[NSLayoutConstraint
                            constraintWithItem:_border attribute:NSLayoutAttributeWidth
                            relatedBy:NSLayoutRelationEqual
                            toItem:_border attribute:NSLayoutAttributeHeight
                            multiplier:3.0f constant:0.0f]];
    [_border addConstraint:[NSLayoutConstraint
                            constraintWithItem:_border attribute:NSLayoutAttributeWidth
                            relatedBy:NSLayoutRelationEqual
                            toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                            multiplier:0.0f constant:borderWidth]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:[_border]-20-[backBtn]"
                               options:NSLayoutFormatAlignAllCenterX
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(_border, backBtn)]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initializeLine];
    [self setupCamera];
}

- (void)initializeLine {
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2-lineWidth/2, _border.frame.origin.y+10, lineWidth, 2)];
    line.image = [UIImage imageNamed:@"line"];
    [self.view addSubview:line];
    _line = line;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                             target:self
                                           selector:@selector(lineAnimation)
                                           userInfo:nil
                                            repeats:YES];
}

- (void)lineAnimation {
    if (upOrDown == NO) {
        num ++;
        _line.frame = CGRectMake(_line.frame.origin.x, _border.frame.origin.y+10+2*num, lineWidth, 2);
        if (2*num == borderWidth/3-20) {
            upOrDown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(_line.frame.origin.x, _border.frame.origin.y+10+2*num, lineWidth, 2);
        if (num == 0) {
            upOrDown = NO;
        }
    }
}

- (void)setupCamera {
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    
    if ([_session canAddInput:_input]) {
        [_session addInput:_input];
    }
    if ([_session canAddOutput:_output]) {
        [_session addOutput:_output];
    }
    
    // 条码类型 EAN-13
    _output.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code];
    
    // Preview
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    NSLog(@"%@", NSStringFromCGRect(_border.frame));
    _previewLayer.frame = CGRectMake(self.view.frame.size.width/2-borderWidth/2, self.view.frame.size.height/2-borderWidth/6, borderWidth, borderWidth/3);
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    
    [_session startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    NSString *stringValue;
    
    if ([metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = [metadataObject stringValue];
    }
    
    [_session stopRunning];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [timer invalidate];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SearchBookAccordingtoEAN13"
                                                            object:nil
                                                          userInfo:@{@"code": stringValue}];
    }];
}

- (void)backAction {
    [_session stopRunning];
    [self dismissViewControllerAnimated:YES completion:^{
        [timer invalidate];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
