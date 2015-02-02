//
//  TossTileView.m
//  NetworkingDemo
//
//  Created by Kyle Bailey on 2/2/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//

#import "TossTileView.h"
#import "ViewController.h"

@implementation TossTileView

ViewController *superview;

- (void) touchesBegan: (NSSet*) touches withEvent: (UIEvent*) event
{
    [[self superVC] tossWasTouched: [touches anyObject]];
}

-(ViewController *)superVC {
    return [ViewController sharedViewController];
}


@end
