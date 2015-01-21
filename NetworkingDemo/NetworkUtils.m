//
//  NetworkUtils.m
//  NetworkingDemo
//
//  Created by Kyle Bailey on 1/16/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//

#import "NetworkUtils.h"
@implementation NetworkUtils

+(void)sendLetterPlayed:(NSString *)update
{
    [[WarpClient getInstance] sendChat:update];
}

+(void)sendWordPlayed:(NSString *)update
{
    [[WarpClient getInstance] sendChat:update]; 
}

+(void)sendLetterRemoved:(NSString *)update
{
    [[WarpClient getInstance] sendChat:update];
}

@end