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
+(void)sendFinalLetterPlayed:(NSString *)theUpdate
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

+(void)sendLetterFinalRemoved:(NSString *)update
{
    [[WarpClient getInstance] sendChat:update];
}
+(void)sendPlayerScore:(NSString *)score {
    NSString* message = [NSString stringWithFormat:@"score:%@", score];
    [[WarpClient getInstance] sendChat:message];
}


+(void)sendJoinedLobby
{
    NSString* message = [NSString stringWithFormat:@"joined"];
    [[WarpClient getInstance] sendChat:message];
}

+(void)sendStartingWord:(NSString *)word {
    NSString* message = [NSString stringWithFormat:@"startingWord:%@", word];
    [[WarpClient getInstance] sendChat:message];
}

+(void)sendUpdateColor:(NSString *)color forPlayer:(NSString *)player {
    NSString* message = [NSString stringWithFormat:@"colorUpdate:%@:%@", color, player];
    [[WarpClient getInstance] sendChat:message];
}

+(void)sendStartGame
{
    NSString* message = [NSString stringWithFormat:@"start"];
    [[WarpClient getInstance] sendChat:message];
}

+(void)joinRoom
{
    [[WarpClient getInstance] joinRoom:ROOM_ID];
}

+(void)createRoom
{
    //[[WarpClient getInstance] joinRoom:ROOM_ID];
    NSDictionary *properties = [[NSDictionary alloc] init];
    for(int i = 0; i < 100; i++){
        [properties setValue:@"-" forKey:[NSString stringWithFormat:@"%d",i]];
    }
    [[WarpClient getInstance] createRoomWithRoomName:@"propertyRoom" roomOwner:@"admin" properties:properties maxUsers:4];
}

@end