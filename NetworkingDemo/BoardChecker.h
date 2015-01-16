//
//  BoardChecker.h
//  NetworkingDemo
//
//  Created by Margaret Kelley on 1/14/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameConstants.h"

@interface BoardChecker : NSObject

+(BOOL)checkBoardState:(NSArray *)board;
+(BOOL)isValid:(NSString *)word;

@end
