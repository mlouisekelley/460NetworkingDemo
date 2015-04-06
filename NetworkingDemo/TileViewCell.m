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
#import "GameHost.h"
#import "BoardChecker.h"
@implementation TileViewCell


CGPoint offset;
ViewController *superview;

-(id)initWithFrame:(CGRect)frame letter:(NSString*)letter playerUserName:(NSString *)playerID{
    _isStartingTile = NO;
    if (self = [super initWithFrame:frame]) {
        if ([playerID isEqualToString:[GameConstants getUserName]]) {
            [self setBackgroundColor:[UIColor orangeColor]];
        }
        else {
            if([playerID isEqualToString:@"stone"]){
                [self setBackgroundColor:[UIColor blackColor]];
                [self setBackgroundColor:[self.backgroundColor colorWithAlphaComponent:0.5]];
                _isStartingTile = YES;
            } else {
                [self setBackgroundColor:[UIColor blueColor]];
            }
        }
        self.letterLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 4, 64, 64)];
        self.letterLabel.text = letter;
        self.letterLabel.font = [UIFont fontWithName:@"orange juice" size:54];
        _startPoint = self.frame.origin;
        [self addSubview:self.letterLabel];
        
        self.pointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(48, 40, 24, 24)];
        self.pointsLabel.text = [NSString stringWithFormat:@"%d", [BoardChecker getScoreForLetter:self.letterLabel.text]];
        [self addSubview:self.pointsLabel];
        
        _pid = playerID;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        tapGesture.numberOfTapsRequired = 2;
        [self addGestureRecognizer:tapGesture];
        superview = nil;
        self.userInteractionEnabled = YES;
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame playerID:(NSString *)playerID {
    _isOnRack = YES;
    return [self initWithFrame:frame letter:[self getRandomUppercaseLetter] playerUserName:playerID];
}

-(void)awakeFromNib {
    [super awakeFromNib];
    superview = nil;
    _letterLabel.text = [self getRandomUppercaseLetter];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 2;
    [self addGestureRecognizer:tapGesture];
    self.userInteractionEnabled = YES;
}

-(void) makeSelected {
    [self setBackgroundColor:[self.backgroundColor colorWithAlphaComponent:0.5]];
    UIColor *ourColor = [[GameHost sharedGameHost] getColorForPlayer:_pid];
    if ([ourColor isEqual:[UIColor orangeColor]]) {
        [self setImage:[UIImage imageNamed:@"TilePressed"]];
    }
    _isSelected = YES;
}

-(void) makeUnselected {
    [self setBackgroundColor:[self.backgroundColor colorWithAlphaComponent:1.0]];
    UIColor *ourColor = [[GameHost sharedGameHost] getColorForPlayer:_pid];
    if ([ourColor isEqual:[UIColor orangeColor]]) {
        [self setImage:[UIImage imageNamed:@"tile.png"]];
    }
    if ([ourColor isEqual:[UIColor purpleColor]]) {
        [self setImage:[UIImage imageNamed:@"tile2.png"]];
    }
    _isSelected = NO;
}


-(void) makeFinalized:(int) multiplier {
//    [self setImage:[UIImage imageNamed:@""]];
    [self setBackgroundColor:[[UIColor yellowColor] colorWithAlphaComponent:1]];
    [self setImage:[UIImage imageNamed:@"TileFinal"]];
    int numParticles = 15;
    int particleSize = 4;
    
    // Particle effects
    
    for (int i = 0; i < numParticles; i++) {
        float particleLength = ((double)arc4random() / 0x100000000) + .5 ;
        int edge = i % 4;
        UIView *particleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, particleSize, particleSize)];
        if (edge == 0)
            particleView.frame = CGRectMake(arc4random_uniform(self.frame.size.width), 0, particleSize, particleSize);
        if (edge == 1)
            particleView.frame = CGRectMake(0, arc4random_uniform(self.frame.size.height), particleSize, particleSize);
        if (edge == 2)
            particleView.frame = CGRectMake(arc4random_uniform(self.frame.size.width), self.frame.size.height, particleSize, particleSize);
        if (edge == 3)
            particleView.frame = CGRectMake(self.frame.size.width, arc4random_uniform(self.frame.size.height), particleSize, particleSize);

        CGFloat hue, saturation, brightness, alpha ;
        float randHue = ((double)arc4random() / 0x100000000);
        
        UIColor *ourColor = [[GameHost sharedGameHost] getColorForPlayer:_pid];
        [ ourColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha ] ;
        
        UIColor * newColor = [ UIColor colorWithHue:hue saturation:randHue brightness:brightness alpha:alpha ] ;
        particleView.backgroundColor = newColor;

        [self addSubview:particleView];

        [UIView animateWithDuration:particleLength animations:^{
            
            [particleView setAlpha:0.0f];
            int maxDist = 100;
            int xDist = arc4random_uniform(maxDist * 2) - maxDist;
            int yDist = arc4random_uniform(maxDist * 2) - maxDist;
            if (edge == 0) {
                yDist = -1 * arc4random_uniform(maxDist);
            }
            if (edge == 1) {
                xDist = -1 * arc4random_uniform(maxDist);
            }
            if (edge == 2) {
                yDist = arc4random_uniform(maxDist);
            }
            if (edge == 3) {
                xDist = arc4random_uniform(maxDist);
            }
            [particleView setFrame:CGRectMake(particleView.frame.origin.x + xDist, particleView.frame.origin.y + yDist, particleView.frame.size.width, particleView.frame.size.height)];
        } completion:^(BOOL finished) {
            [particleView removeFromSuperview];
            }];
    }
    
    // Score Increaser
    if (!_isFinalized) {
        double scoreXLabel = self.frame.origin.x + arc4random_uniform(self.frame.size.width);
        double scoreYLabel = self.frame.origin.y;
        UILabel *scoreIncreasedLabel = [[UILabel alloc] initWithFrame:CGRectMake(scoreXLabel, scoreYLabel, self.frame.size.width, self.frame.size.height)];
        scoreIncreasedLabel.font = [UIFont fontWithName:@"orange juice" size:32];
        scoreIncreasedLabel.text = [NSString stringWithFormat:@"+ %d", [BoardChecker getScoreForLetter:self.letterLabel.text]* multiplier];
        scoreIncreasedLabel.textColor = [[GameHost sharedGameHost] getColorForPlayer:_pid];
        [[self superVC].view addSubview:scoreIncreasedLabel];
        double scoreFadeLength = 1.0;
    //    double scoreXDist = arc4random_uniform(20)-10;
    //    double scoreYDist = arc4random_uniform(20)-10;
            double scoreXDist = 0;
            double scoreYDist = -20;
    //    NSLog(scoreXDist)
        [UIView animateWithDuration:scoreFadeLength animations:^{
            
            [scoreIncreasedLabel setAlpha:0.0f];
            [scoreIncreasedLabel setFrame:CGRectMake(scoreIncreasedLabel.frame.origin.x + scoreXDist, scoreIncreasedLabel.frame.origin.y + scoreYDist, scoreIncreasedLabel.frame.size.width, scoreIncreasedLabel.frame.size.height)];
        } completion:^(BOOL finished) {
            [scoreIncreasedLabel removeFromSuperview];
        }];
    }
    
    _isFinalized = YES;


}

-(void) makeBeingMovedByOtherPlayer {
    _isBeingMovedByOtherPlayer = YES;
    UIColor *color = self.backgroundColor;
    [self setBackgroundColor:[color colorWithAlphaComponent:0.3]];
}
-(void) unMakeBeingMovedByOtherPlayer {
    _isBeingMovedByOtherPlayer = NO;
    UIColor *color = self.backgroundColor;
    [self setBackgroundColor:[color colorWithAlphaComponent:1]];
}
-(void) setColorOfTile:(UIColor *)color {
    [self setBackgroundColor:color];
    if ([color isEqual:[UIColor orangeColor]]) {
        UIImage *tileImg = [UIImage imageNamed:@"tile.png"];
        [self setImage:tileImg];
    }
    if ([color isEqual:[UIColor purpleColor]]) {
        [self setImage:[UIImage imageNamed:@"tile2.png"]];
    }

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([[self superVC] touchToPlay] && !_isStartingTile){
        if (!_isSelected || (_isSelected && [_pid isEqualToString:[GameConstants getUserName]])) {
            if([[self superVC] tileIsSelected]){
                [[self superVC] clearSelectedTile];
                
            }
            [[self superVC] setSelectedTile:self];
        }
        
    }
    
    if (!_isSelected && !_isStartingTile) {
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
    if (!_isSelected && !_isStartingTile) {
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
    if (!_isSelected && !_isStartingTile) {

        [[self superVC] tileDidFinishMoving:self];
        
        [UIView animateWithDuration:0.1 animations:^{
            self.frame = CGRectMake(_startPoint.x, _startPoint.y, self.frame.size.width, self.frame.size.height);
        }];
            
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        [[self superVC] takeTileFromBoard:self];
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
