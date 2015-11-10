//
//  LQRootViewController.h
//  Liquid
//
//  Created by Miguel M. Almeida on 02/11/15.
//  Copyright © 2015 Liquid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LQRootViewController : UIViewController

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
@property (nonatomic, assign) NSUInteger interfaceOrientationMask;
#else
@property (nonatomic, assign) UIInterfaceOrientationMask interfaceOrientationMask;
#endif

@end
