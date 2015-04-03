//
//  TutorialTile.m
//  WordPlay
//
//  Created by David A Nichol on 4/3/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//


#import "TutorialTile2.h"

@implementation TutorialTile2
UIViewController *superview;

-(void)awakeFromNib {
    [super awakeFromNib];
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 2;
    [self addGestureRecognizer:tapGesture];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        [UIView animateWithDuration:0.1 animations:^{
            self.frame = CGRectMake(547, 773, self.frame.size.width, self.frame.size.height);
        } completion:^(BOOL finished){
            self.frame = CGRectMake(547, 773, self.frame.size.width, self.frame.size.height);
            [[self superVC] performSegueWithIdentifier:@"b" sender:[self superVC]];
        }];
    
    }
}
-(UIViewController *)superVC {
    UIResponder* nextResponder = [self.superview nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
    {
        superview =  (UIViewController*)nextResponder;
    }
    
    return superview;
}
@end
