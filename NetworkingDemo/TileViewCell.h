//
//  TileViewCell.h
//  NetworkingDemo
//
//  Created by Margaret Kelley on 12/25/14.
//  Copyright (c) 2014 Margaret Kelley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface TileViewCell : UIView

@property (strong, nonatomic) IBOutlet UILabel *letterLabel;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) BOOL isOnRack;
@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) BOOL isSelected;
@property (nonatomic) BOOL isFinalized;
@property (nonatomic) BOOL isStartingTile;
@property (nonatomic, strong) NSString *pid;
@property (nonatomic) BOOL isUnsent;
@property (nonatomic) BOOL isBeingMovedByOtherPlayer;

-(id)initWithFrame:(CGRect)frame letter:(NSString*)letter playerUserName:(NSString *)playerID;
-(id)initWithFrame:(CGRect)frame playerID:(NSString *)playerID;
-(void) makeFinalized:(int) multiplier;
-(void) makeSelected;
-(void) makeUnselected;
-(void) makeBeingMovedByOtherPlayer;
-(void) unMakeBeingMovedByOtherPlayer;
-(void) setColorOfTile:(UIColor *)color;
@end
