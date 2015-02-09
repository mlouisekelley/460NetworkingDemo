//
//  NetworkUtils.m
//  NetworkingDemo
//
//  Created by Kyle Bailey on 1/16/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//

#import "NetworkUtils.h"
@implementation NetworkUtils

+(void)sendLetterPlayed:(NSString *)theUpdate
{
    [[WarpClient getInstance] sendChat:theUpdate];
}

+(void)sendWordPlayed
{
    NSString* message = [NSString stringWithFormat:@"wp"];
    [[WarpClient getInstance] sendChat:message];
}

//String should just be index path item of letter removed
+(void)sendLetterRemoved:(NSString *)update
{
    [[WarpClient getInstance] sendChat:update];
}

+(void)sendPlayerScore:(NSString *)score {
    NSString* message = [NSString stringWithFormat:@"score:%@", score];
    [[WarpClient getInstance] sendChat:message];
}

+(void)sendJoinedGame
{
    NSString* message = [NSString stringWithFormat:@"joined"];
    [[WarpClient getInstance] sendChat:message];
}

@end