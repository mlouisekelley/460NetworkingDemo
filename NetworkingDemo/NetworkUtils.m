//
//  NetworkUtils.m
//  NetworkingDemo
//
//  Created by Kyle Bailey on 1/16/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//

#import "NetworkUtils.h"
#import <Parse/Parse.h>
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
    NSLog(@"----Startgame");
    PFQuery *query = [PFQuery queryWithClassName:@"RoomData"];
    [query whereKey:@"roomId" equalTo:[GameConstants getSubscribedRoom]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for(PFObject *object in objects){
            object[@"gameStarted"] = @YES;
            [object saveInBackground];
        }
    }];
    
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
    NSLog(@"Join Room Called");
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
    NSLog(@"CREATING ROOM");
    NSDictionary *roomProps = @{@"0" : @0, @"1" : @0, @"2" : @0, @"3" : @0, @"4" : @0, @"5" : @0, @"6" : @0, @"7" : @0, @"8" : @0, @"9" : @0,
                                @"10" : @0, @"11" : @0, @"12" : @0, @"13" : @0, @"14" : @0, @"15" : @0, @"16" : @0, @"17" : @0, @"18" : @0, @"19" : @0,
                                @"20" : @0, @"21" : @0, @"22" : @0, @"23" : @0, @"24" : @0, @"25" : @0, @"26" : @0, @"27" : @0, @"28" : @0, @"29" : @0,
                                @"30" : @0, @"31" : @0, @"32" : @0, @"33" : @0, @"34" : @0, @"35" : @0, @"36" : @0, @"37" : @0, @"38" : @0, @"39" : @0,
                                @"40" : @0, @"41" : @0, @"42" : @0, @"43" : @0, @"44" : @0, @"45" : @0, @"44" : @0, @"47" : @0, @"48" : @0, @"49" : @0,
                                @"50" : @0, @"51" : @0, @"52" : @0, @"53" : @0, @"54" : @0, @"55" : @0, @"56" : @0, @"57" : @0, @"58" : @0, @"59" : @0,
                                @"60" : @0, @"61" : @0, @"62" : @0, @"63" : @0, @"64" : @0, @"65" : @0, @"66" : @0, @"67" : @0, @"68" : @0, @"69" : @0,
                                @"70" : @0, @"71" : @0, @"72" : @0, @"73" : @0, @"74" : @0, @"75" : @0, @"76" : @0, @"77" : @0, @"78" : @0, @"79" : @0,
                                @"80" : @0, @"81" : @0, @"82" : @0, @"83" : @0, @"84" : @0, @"85" : @0, @"86" : @0, @"87" : @0, @"88" : @0, @"89" : @0,
                                @"90" : @0, @"91" : @0, @"92" : @0, @"93" : @0, @"94" : @0, @"95" : @0, @"96" : @0, @"97" : @0, @"98" : @0, @"99" : @0,
                                };
    [[WarpClient getInstance] createRoomWithRoomName:name roomOwner:[GameConstants getUserName] properties:roomProps maxUsers:players];
}

+(void)generateAndSendStartingWord
{
    NSArray *starting_words = @[@"ABOUT", @"ABOVE", @"AFTER", @"AGAIN", @"ALONG", @"BEGAN", @"BEGIN", @"BEING", @"BELOW",  @"BIRDS", @"BLACK", @"CARRY", @"CLOSE", @"COLOR", @"COULD", @"EARLY", @"EARTH", @"EVERY", @"FACET", @"FIRST", @"FOUND", @"GREAT", @"GROUP", @"HEARD", @"HORSE", @"HOURS", @"HOUSE", @"LARGE", @"LEARN", @"LEAVE", @"LIGHT", @"MIGHT", @"MUSIC", @"NEVER", @"NIGHT", @"OFTEN", @"ORDER", @"OTHER", @"PAPER", @"PIECE", @"PLACE", @"PLANT", @"POINT", @"RIGHT", @"RIVER", @"SHORT", @"SINCE", @"SMALL", @"SOUND", @"SPELL", @"STAND", @"START", @"STATE", @"STILL", @"STORY", @"STUDY", @"THEIR", @"THERE", @"THESE", @"THING", @"THINK", @"THOSE", @"THREE", @"TODAY", @"UNDER", @"UNTIL", @"WAVES", @"WHERE", @"WHICH", @"WHILE", @"WHITE", @"WHOLE", @"WORLD", @"WOULD", @"WRITE", @"YOUNG"];
    NSString *starting_word = [starting_words objectAtIndex: arc4random() % [starting_words count]];
    NSString* message = [NSString stringWithFormat:@"startingWord:%@", starting_word];
    [[WarpClient getInstance] sendChat:message];
}

+(void)deleteAllParseRoomInfo
{
    PFQuery *query = [PFQuery queryWithClassName:@"RoomData"];
    // Retrieve the object by id
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"DELETING %lu rooms", (unsigned long)[objects count]);
        for (PFObject *object in objects) {
            [object deleteInBackground];
        }
    }];
}

+(void)deleteAllAppWarpRooms
{
    [[WarpClient getInstance] getAllRooms];
}

@end