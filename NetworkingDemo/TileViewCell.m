//
//  TileViewCell.m
//  NetworkingDemo
//
//  Created by Margaret Kelley on 12/25/14.
//  Copyright (c) 2014 Margaret Kelley. All rights reserved.
//

#import "TileViewCell.h"
#import "ViewController.h"
#import "GameConstants.h"

@implementation TileViewCell


CGPoint offset;
ViewController *superview;
NSString *pid;

-(id)initWithFrame:(CGRect)frame letter:(NSString*)letter playerUserName:(NSString *)playerID{
    if (self = [super initWithFrame:frame]) {
        if ([playerID isEqualToString:[GameConstants getUserName]]) {
            [self setBackgroundColor:[UIColor orangeColor]];
        }
        else {
            [self setBackgroundColor:[UIColor blueColor]];
        }
        self.letterLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 12, 42, 21)];
        self.letterLabel.text = letter;
        _startPoint = self.frame.origin;
        [self addSubview:self.letterLabel];
        pid = playerID;
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame playerID:(NSString *)playerID {
    _isNotOnBoard = YES;
    return [self initWithFrame:frame letter:[self getRandomUppercaseLetter] playerUserName:playerID];
}

-(void)awakeFromNib {
    [super awakeFromNib];
    _letterLabel.text = [self getRandomUppercaseLetter];
}

-(void) makePending {
    [self setBackgroundColor:[self.backgroundColor colorWithAlphaComponent:0.5]];
    _isPending = YES;
}

-(void) makeFinalized {
    [self setBackgroundColor:[[UIColor yellowColor] colorWithAlphaComponent:1]];
    _isPending = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_isPending) {
        [super touchesBegan:touches withEvent:event];
        UITouch *aTouch = [touches anyObject];
        offset = [aTouch locationInView: self];
        CGPoint location = [aTouch locationInView:self.superview];
        
        self.frame = CGRectMake(location.x-offset.x, location.y-offset.y,
                                self.frame.size.width, self.frame.size.height);
        [UIView commitAnimations];
    }
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_isPending) {
        UITouch *aTouch = [touches anyObject];
        CGPoint location = [aTouch locationInView:self.superview];
        
        self.frame = CGRectMake(location.x-offset.x, location.y-offset.y,
                                self.frame.size.width, self.frame.size.height);
        [UIView commitAnimations];
        
        [[self superVC] tileDidMove:self];
    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_isPending) {

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
}

-(NSString *)getRandomUppercaseLetter {
    NSString *letters = @"AAAAAAAAABBCCDDDDEEEEEEEEEEEEFFGGGHHIIIIIIIIIJKLLLLMMNNNNNNOOOOOOOOPPQRRRRRRSSSSTTTTTTUUUUVVWWXYYZ";
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
