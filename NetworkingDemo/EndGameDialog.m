//
//  BarTimerView.m
//  WordPlay
//
//  Created by David A Nichol on 3/14/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EndGameDialog.h"
#import "ViewController.h"
@implementation EndGameDialog

- (IBAction)touchHome:(id)sender {
    [[self superVC] goHome];
}
- (IBAction)touchRematch:(id)sender {
    [[self superVC] goRematch];
}

-(ViewController *)superVC {
    UIResponder* nextResponder = [self.superview nextResponder];
    
    if ([nextResponder isKindOfClass:[ViewController class]])
    {
        return (ViewController*)nextResponder;
    }
    return nil;
}


@end