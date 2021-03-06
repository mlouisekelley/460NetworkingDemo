//
//  BoardViewCell.h
//  NetworkingDemo
//
//  Created by Margaret Kelley on 12/25/14.
//  Copyright (c) 2014 Margaret Kelley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TileViewCell.h"
#import "Player.h"
@interface BoardCellDTO : NSObject

@property (nonatomic) TileViewCell* tvc;
@property (strong, nonatomic) UICollectionViewCell *cell;
@property (nonatomic) int isPending;
@property (nonatomic) BOOL tileWasHere;
@property (nonatomic) Player *player;

@end
