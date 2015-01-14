//
//  TileViewCell.m
//  NetworkingDemo
//
//  Created by Margaret Kelley on 12/25/14.
//  Copyright (c) 2014 Margaret Kelley. All rights reserved.
//

#import "TileViewCell.h"
#import "ViewController.h"

@implementation TileViewCell


CGPoint offset, startPoint;
ViewController *superview;
-(void)awakeFromNib {
    [super awakeFromNib];
    _letterLabel.text = [self getRandomUppercaseLetter];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    UITouch *aTouch = [touches anyObject];
    startPoint = self.frame.origin;
    offset = [aTouch locationInView: self];
    CGPoint location = [aTouch locationInView:self.superview];
    
    self.frame = CGRectMake(location.x-offset.x, location.y-offset.y,
                            self.frame.size.width, self.frame.size.height);
    [UIView commitAnimations];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView:self.superview];
    
    self.frame = CGRectMake(location.x-offset.x, location.y-offset.y,
                            self.frame.size.width, self.frame.size.height);
    [UIView commitAnimations];
    
    [[self superVC] tileDidMove:self];
}
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    BOOL shouldDisappear = [[self superVC] tileDidFinishMoving:self];
    
    if (shouldDisappear) {
        [self removeFromSuperview];
    }
    else {
        [UIView animateWithDuration:0.1 animations:^{
            self.frame = CGRectMake(startPoint.x, startPoint.y, self.frame.size.width, self.frame.size.height);;
        }];
        
    }
}

-(NSString *)getRandomUppercaseLetter {
    NSString *letters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSString *str = @"";
    str = [str stringByAppendingFormat:@"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    return str;
}
-(ViewController *)superVC {
    if (superview == nil) {
        UIResponder* nextResponder = [self.superview nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            superview =  (ViewController*)nextResponder;
        }
    }
    return superview;
}
@end
