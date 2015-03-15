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

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        UIImageView *tempImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"EmptyCell"]];
        tempImgView.frame = CGRectMake(0, 0, 64, 64);
        [self addSubview:tempImgView];
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *tempImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"EmptyCell"]];
        tempImgView.frame = self.frame;
        [self addSubview:tempImgView];
    }
    return self;
}
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
