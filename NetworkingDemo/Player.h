//  TileViewCell.h
//  NetworkingDemo
//
//  Created by Margaret Kelley on 12/25/14.
//  Copyright (c) 2014 Margaret Kelley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface Player : NSObject

@property (nonatomic) int numberOfTiles;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic) int score;
@property (nonatomic) UIColor *color;
@property (nonatomic) int playerNumber;
@end