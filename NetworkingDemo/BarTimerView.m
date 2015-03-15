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
double initWidth = -1;
UIImageView *tempImgView;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        tempImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TimeBar"]];
        tempImgView.frame = self.frame;
        initWidth = -1;
        [self addSubview:tempImgView];    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        tempImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TimeBar"]];
        tempImgView.frame = self.frame;
        initWidth = -1;
        [self addSubview:tempImgView];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (initWidth == -1) {
        initWidth = self.frame.size.width;
    }
    tempImgView.frame = CGRectMake(0, 0, initWidth * self.percent, self.frame.size.height);
//    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, initWidth * self.percent, self.frame.size.height);

}

@end