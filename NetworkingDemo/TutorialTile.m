//
//  TutorialTile.m
//  WordPlay
//
//  Created by David A Nichol on 4/3/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//


#import "TutorialTile.h"
@implementation TutorialTile
CGPoint offset;
UIViewController *superview;

-(id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
    }
    return self;
}
-(void)awakeFromNib {
    [super awakeFromNib];
    self.userInteractionEnabled = YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
_startPoint = self.frame.origin;
    UITouch *aTouch = [touches anyObject];
    offset = [aTouch locationInView: self];
    CGPoint location = [aTouch locationInView:[self superVC].view];
        
    self.frame = CGRectMake(location.x-offset.x, location.y-offset.y,self.frame.size.width, self.frame.size.height);
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
        UITouch *aTouch = [touches anyObject];
        CGPoint location = [aTouch locationInView:self.superview];
        
        self.frame = CGRectMake(location.x-offset.x, location.y-offset.y,
                                self.frame.size.width, self.frame.size.height);
       [UIView commitAnimations];
        
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
        [UIView animateWithDuration:0.1 animations:^{
            self.frame = CGRectMake(_startPoint.x, _startPoint.y, self.frame.size.width, self.frame.size.height);
        }];
    [[self superVC] performSegueWithIdentifier:@"a" sender:[self superVC]];
        
}
-(UIViewController *)superVC {
    if (superview == nil) {
        UIResponder* nextResponder = [self.superview nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            superview =  (UIViewController*)nextResponder;
        }
    }
    return superview;
}
@end
