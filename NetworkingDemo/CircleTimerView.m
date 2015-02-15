//
//  CircleTimerView.m
//  NetworkingDemo
//
//  Created by David A Nichol on 2/14/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CircleTimerView.h"
#import "ViewController.h"
@implementation CircleTimerView
float startAngle = M_PI * 1.5;
float endAngle = (3.5 * M_PI);
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
        // Determine our start and stop angles for the arc (in radians)
        startAngle = M_PI * 1.5;
        endAngle = startAngle + (M_PI * 2);
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    self.userInteractionEnabled = NO;
    // Display our percentage as a string
    NSString* textContentSeconds = [NSString stringWithFormat:@"%d", self.seconds];
    NSString* textContentMilliseconds = [NSString stringWithFormat:@"%d", self.milliseconds/10];
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    
    // Create our arc, with the correct angles
    [bezierPath addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                          radius:120
                      startAngle:startAngle
                        endAngle:(endAngle - startAngle) * (self.percent) + startAngle
                       clockwise:YES];
    
    // Set the display for the path, and stroke it
    bezierPath.lineWidth = 20;
    [[UIColor blackColor] setStroke];
    [bezierPath stroke];
    
    // Text Drawing
    if (self.seconds > 5) {
        CGRect textRect = CGRectMake((rect.size.width / 2.0) - 71/2.0, (rect.size.height / 2.0) - 45/2.0, 71, 45);
        [[UIColor blackColor] setFill];
        [textContentSeconds drawInRect: textRect withFont: [UIFont fontWithName: @"Helvetica-Bold" size: 42.5] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
        
        CGRect textRectMS = CGRectMake((rect.size.width / 2.0) - 51/2.0 + 48, (rect.size.height / 2.0) - 25/2.0 - 24, 51, 25);
        [[UIColor blackColor] setFill];
        [textContentMilliseconds drawInRect: textRectMS withFont: [UIFont fontWithName: @"Helvetica-Bold" size: 24] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
    }
}

@end