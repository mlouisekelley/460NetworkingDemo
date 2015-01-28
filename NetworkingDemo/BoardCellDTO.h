//
//  BoardViewCell.h
//  NetworkingDemo
//
//  Created by Margaret Kelley on 12/25/14.
//  Copyright (c) 2014 Margaret Kelley. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface BoardCellDTO : NSObject

@property (strong, nonatomic) NSString* text;
@property (nonatomic, strong) NSString* playerUserName;
@property (nonatomic) int pending;

@end
