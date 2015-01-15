//
//  BoardViewCell.m
//  NetworkingDemo
//
//  Created by Margaret Kelley on 12/25/14.
//  Copyright (c) 2014 Margaret Kelley. All rights reserved.
//

#import "BoardViewCell.h"
#import "ViewController.h"
@implementation BoardViewCell

ViewController *superview;

- (void) touchesBegan: (NSSet*) touches withEvent: (UIEvent*) event
{
    [[self superVC] boardWasTouched: [touches anyObject]];
}

-(ViewController *)superVC {
    if (superview == nil) {
        UIResponder* nextResponder = [self.superview.superview nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            superview =  (ViewController*)nextResponder;
        }
    }
    return superview;
}
@end
