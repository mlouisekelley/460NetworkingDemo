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
    //[[ViewController sharedViewController] addPlayer:username];
}
-(void)onUserLeftLobby:(LobbyData*)lobbyData username:(NSString*)username{
    
}
-(void)onUserJoinedLobby:(LobbyData*)lobbyData username:(NSString*)username{
    
}
-(void)onChatReceived:(ChatEvent*)chatEvent{
    
    if([chatEvent.message isEqualToString:@"start"]){
        [[LobbyViewController sharedViewController] startGame];
        return;
    }
    
    if([chatEvent.message isEqualToString:@"joined"]){
        [[GameHost sharedGameHost] addColorforPlayer:chatEvent.sender];
        if([chatEvent.sender isEqualToString:[GameConstants getUserName]]){
            //[[LobbyViewController sharedViewController] startGame];
            return;
        }
        [[LobbyViewController sharedViewController] playerJoinedLobby];
        return;
    }
    
    [[ViewController sharedViewController] addPlayer:chatEvent.sender];
    
    NSArray *message = [chatEvent.message componentsSeparatedByString:@":"];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[message[0] integerValue]
                                            inSection:0];
    
    if ([message[0] isEqualToString:@"startingWord"]){
        [[GameHost sharedGameHost] setStartingWord:message[1]];
        return;
    }
    
    if ([message[0] isEqualToString:@"colorUpdate"]){
        [self updateColor:message[1] forPlayer:message[2]];
        return;
    }

    //only look at chats from other players
    if(![chatEvent.sender isEqualToString:[GameConstants getUserName]]){
        //letter removed
        if(message.count == 1){
            //word has been played
            if([message[0] isEqualToString:@"wp"]){
                [[ViewController sharedViewController] placeEnemyFinalLetter:message[1]
                                                                   atIndexPath:indexPath forEnemy:chatEvent.sender];
                return;
            }
            [[ViewController sharedViewController]removeEnemyPendingLetterAtIndexPath:indexPath];
            return;
        }
        if([message[0] isEqualToString:@"score"]){
            [[ViewController sharedViewController] updateScore:[message[1] intValue] forPlayer:chatEvent.sender];
            return;
        }
        if([message[0] isEqualToString:@"pendingRemove"]){
            indexPath = [NSIndexPath indexPathForItem:[message[1] integerValue]
                                            inSection:0];
            [[ViewController sharedViewController] setLetterBeingMovedAtIndexPath:indexPath];
            return;
        }
        if ([message[0] isEqualToString:@"removeLetter"]) {
            indexPath = [NSIndexPath indexPathForItem:[message[1] integerValue]
                                            inSection:0];
            [[ViewController sharedViewController] removeEnemyFinalLetterAtIndexPath:indexPath];
            return;
            
        }

        if ([message[0] isEqualToString:@"f"]) {
            for (int i = 1; i < [message count]; i += 3) {
            indexPath = [NSIndexPath indexPathForItem:[message[i+1] integerValue]
                                            inSection:0];
                if ([message[i] isEqualToString:@"a"]) {
            [[ViewController sharedViewController] placeEnemyFinalLetter:message[i+2]
                                                             atIndexPath:indexPath forEnemy:chatEvent.sender];
                }
                else{
                    [[ViewController sharedViewController] removeEnemyFinalLetterAtIndexPath:indexPath];
                    
                }
            }
            return;
        }
        [[ViewController sharedViewController] placeEnemyPendingLetter:message[1]
                                                           atIndexPath:indexPath forEnemy:chatEvent.sender];
    }
}

-(void)updateColor:(NSString *)color forPlayer:(NSString *)userName {
    if([color isEqualToString:@"orange"]){
        [[GameHost sharedGameHost] overrideColor:[UIColor orangeColor] forPlayer:userName];
    }
    if([color isEqualToString:@"purple"]){
        [[GameHost sharedGameHost] overrideColor:[UIColor purpleColor] forPlayer:userName];
    }
    if([color isEqualToString:@"green"]){
        [[GameHost sharedGameHost] overrideColor:[UIColor greenColor] forPlayer:userName];
    }
    if([color isEqualToString:@"blue"]){
        [[GameHost sharedGameHost] overrideColor:[UIColor blueColor] forPlayer:userName];
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
