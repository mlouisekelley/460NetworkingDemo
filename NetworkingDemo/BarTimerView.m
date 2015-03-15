//
//  BarTimerView.m
//  WordPlay
//
//  Created by David A Nichol on 3/14/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "BarTimerView.h"

@implementation BarTimerView
double initWidth;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        initWidth = self.frame.size.width;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, initWidth * self.percent, self.frame.size.height);
}

@end