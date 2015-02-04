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
@property (nonatomic) BOOL isNotOnBoard;
@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) BOOL isPending;
@property (nonatomic) BOOL isSelected;
@property (nonatomic) BOOL isStartingTile;
-(id)initWithFrame:(CGRect)frame letter:(NSString*)letter playerUserName:(NSString *)playerID;
-(id)initWithFrame:(CGRect)frame playerID:(NSString *)playerID;
-(void) makePending;
-(void) makeFinalized;
-(void) makeSelected;
-(void) makeUnselected;
@end
