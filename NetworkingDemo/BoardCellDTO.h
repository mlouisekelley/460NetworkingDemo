//
//  BoardViewCell.h
//  NetworkingDemo
//
//  Created by Margaret Kelley on 12/25/14.
//  Copyright (c) 2014 Margaret Kelley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TileViewCell.h"
@interface BoardCellDTO : NSObject

@property (strong, nonatomic) NSString* text;
@property (nonatomic) TileViewCell* tvc;
@property (nonatomic) BOOL isPending;
@property (nonatomic) BOOL tileWasHere;

@end
