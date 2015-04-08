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

+(void)sendLetterReturned:(NSString *)update
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
    NSLog(@"Sending a message");
    NSString* message = [NSString stringWithFormat:@"joined"];
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

+(void)sendWaitingForRematch
{
    NSString* message = [NSString stringWithFormat:@"rematchPending"];
    [[WarpClient getInstance] sendChat:message];
}

+(void)sendRematchDenied
{
    NSString* message = [NSString stringWithFormat:@"rematchDenied"];
    [[WarpClient getInstance] sendChat:message];
}

+(void)sendStartRematch
{
    NSString* message = [NSString stringWithFormat:@"rematch"];
    [[WarpClient getInstance] sendChat:message];
}

+(void)joinRoom
{
    NSString *roomId = [GameConstants getRoomIdToJoin];
    if(roomId){
        [[WarpClient getInstance] joinRoom:roomId];
    } else {
        NSLog(@"ERROR: ROOM ID WAS NOT SET FOR ROOM YOU WANTED TO JOIN");
    }
}

+(void)createRoom
{
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    for(int i = 0; i < 100; i++){
        [properties setObject:@"-" forKey:[NSString stringWithFormat:@"%d",i]];
    }
    [[WarpClient getInstance] createRoomWithRoomName:@"propertyRoom" roomOwner:@"admin" properties:properties maxUsers:4];
}

+(void)createRoomWithName:(NSString *)name andNumPlayers:(int)players
{
    [[WarpClient getInstance] createRoomWithRoomName:name roomOwner:[GameConstants getUserName] properties:nil maxUsers:players];
}

+(void)generateAndSendStartingWord
{
    NSArray *starting_words = @[@"ABOUT", @"ABOVE", @"AFTER", @"AGAIN", @"ALONG", @"BEGAN", @"BEGIN", @"BEING", @"BELOW",  @"BIRDS", @"BLACK", @"CARRY", @"CLOSE", @"COLOR", @"COULD", @"EARLY", @"EARTH", @"EVERY", @"FACET", @"FIRST", @"FOUND", @"GREAT", @"GROUP", @"HEARD", @"HORSE", @"HOURS", @"HOUSE", @"LARGE", @"LEARN", @"LEAVE", @"LIGHT", @"MIGHT", @"MUSIC", @"NEVER", @"NIGHT", @"OFTEN", @"ORDER", @"OTHER", @"PAPER", @"PIECE", @"PLACE", @"PLANT", @"POINT", @"RIGHT", @"RIVER", @"SHORT", @"SINCE", @"SMALL", @"SOUND", @"SPELL", @"STAND", @"START", @"STATE", @"STILL", @"STORY", @"STUDY", @"THEIR", @"THERE", @"THESE", @"THING", @"THINK", @"THOSE", @"THREE", @"TODAY", @"UNDER", @"UNTIL", @"WAVES", @"WHERE", @"WHICH", @"WHILE", @"WHITE", @"WHOLE", @"WORLD", @"WOULD", @"WRITE", @"YOUNG"];
    NSString *starting_word = [starting_words objectAtIndex: arc4random() % [starting_words count]];
    NSString* message = [NSString stringWithFormat:@"startingWord:%@", starting_word];
    [[WarpClient getInstance] sendChat:message];
}

@end