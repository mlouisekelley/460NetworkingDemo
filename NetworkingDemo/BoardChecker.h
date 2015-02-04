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

+(NSArray *)checkBoardState:(NSArray *)board;
+(BOOL)isValid:(NSString *)word;
+(NSUInteger)calculateScoreForBoard:(NSArray *)board ;
@end
