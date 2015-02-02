//
//  NotificationListener.m
//  AppWarp_Project
//
//  Created by Shephertz Technology on 06/08/12.
//  Copyright (c) 2012 ShephertzTechnology PVT LTD. All rights reserved.
//

#import "NotificationListener.h"

@implementation NotificationListener

@synthesize helper;

-(id)initWithHelper:(id)l_helper
{
    self.helper = l_helper;
    return self;
}

-(void)onRoomCreated:(RoomData*)roomEvent{
    
}
-(void)onRoomDestroyed:(RoomData*)roomEvent{
    
}
-(void)onUserLeftRoom:(RoomData*)roomData username:(NSString*)username
{
    //NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"Error:",@"title",@"Your enemy left the room!",@"message", nil];
    //[[AppWarpHelper sharedAppWarpHelper] onConnectionFailure:dict];
}
-(void)onUserJoinedRoom:(RoomData*)roomData username:(NSString*)username
{
   //[[AppWarpHelper sharedAppWarpHelper] getAllUsers];
    [[ViewController sharedViewController] addPlayer:username];
}
-(void)onUserLeftLobby:(LobbyData*)lobbyData username:(NSString*)username{
    
}
-(void)onUserJoinedLobby:(LobbyData*)lobbyData username:(NSString*)username{
    
}
-(void)onChatReceived:(ChatEvent*)chatEvent{
    
    NSArray *message = [chatEvent.message componentsSeparatedByString:@","];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[message[0] integerValue]
                                            inSection:0];

    
    if([chatEvent.sender isEqualToString:[GameConstants getUserName]]){
        NSLog(@"Chat successfully sent");
    } else {
        NSLog(@"Recieved chat");
        //letter removed
        if(message.count == 1){
            if([message[0] isEqualToString:@"wp"]){
                [[ViewController sharedViewController] finalizePendingEnemyTilesForPlayer:chatEvent.sender];
                return;
            }
            [[ViewController sharedViewController]removeEnemyLetterAtIndexPath:indexPath];
            return;
        }
        [[ViewController sharedViewController] placeEnemyPendingLetter:message[1]
                                                           atIndexPath:indexPath forEnemy:chatEvent.sender];
    }
}

-(void)onUpdatePeersReceived:(UpdateEvent*)updateEvent
{
    //[helper receivedEnemyStatusData:updateEvent.update];
}

-(void)onUserChangeRoomProperty:(RoomData *)event username:(NSString *)username properties:(NSDictionary *)properties lockedProperties:(NSDictionary *)lockedProperties
{
    
}

-(void)onMoveCompleted:(MoveEvent *)moveEvent
{
    
}

-(void)onPrivateChatReceived:(NSString *)message fromUser:(NSString *)senderName
{
    
}

-(void)onUserPaused:(NSString *)userName withLocation:(NSString *)locId isLobby:(BOOL)isLobby
{
    
}

@end
