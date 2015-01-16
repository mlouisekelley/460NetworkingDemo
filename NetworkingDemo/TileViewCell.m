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


CGPoint offset;
ViewController *superview;
-(id)initWithFrame:(CGRect)frame letter:(NSString*)letter{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor orangeColor]];
        self.letterLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, 42, 21)];
        self.letterLabel.text = letter;
        [self addSubview:self.letterLabel];
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame letter:[self getRandomUppercaseLetter]];
}
-(void)awakeFromNib {
    [super awakeFromNib];
    _letterLabel.text = [self getRandomUppercaseLetter];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    UITouch *aTouch = [touches anyObject];
    _startPoint = self.frame.origin;
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
            self.frame = CGRectMake(_startPoint.x, _startPoint.y, self.frame.size.width, self.frame.size.height);
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
