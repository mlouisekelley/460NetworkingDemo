//
//  CircleTimerView.h
//  NetworkingDemo
//
//  Created by David A Nichol on 2/14/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface CircleTimerView : UIView
@property (nonatomic) float percent;
@property (nonatomic) int seconds;
@property (nonatomic) int milliseconds;
@end
