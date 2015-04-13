//
//  RoomListener.m
//  AppWarp_Project
//
//  Created by Shephertz Technology on 06/08/12.
//  Copyright (c) 2012 ShephertzTechnology PVT LTD. All rights reserved.
//

#import "RoomListener.h"
@implementation RoomListener

@synthesize helper;

BOOL subscribed = NO;
BOOL joined = NO;

-(id)initWithHelper:(id)l_helper
{
    self.helper = l_helper;
    return self;
}

-(void)onLockPropertiesDone:(Byte)result
{
    
}
-(void)onUnlockPropertiesDone:(Byte)result
{
    
}
-(void)onUpdatePropertyDone:(LiveRoomInfoEvent *)event
{
    
}

-(void)onSubscribeRoomDone:(RoomEvent*)roomEvent{
    
    if (roomEvent.result == SUCCESS)
    {
        NSLog(@"onSubscribeRoomDone  SUCCESS");
        [GameConstants setSubscribedRoom:roomEvent.roomData.roomId];
        if(joined == NO){
            joined = YES;
            [NetworkUtils sendJoinedLobby];
        }
    }
    else
    {
        NSLog(@"onSubscribeRoomDone  Failed");
    }
}

-(void)onUnSubscribeRoomDone:(RoomEvent*)roomEvent{
    if (roomEvent.result == SUCCESS)
    {
        NSLog(@"Unsubscribed from room");
        subscribed = NO;
        [GameConstants setSubscribedRoom:nil];
    }
    else
    {
        
    }
}

-(void)onJoinRoomDone:(RoomEvent*)roomEvent
{
   NSLog(@".onJoinRoomDone..on Join room listener called");
    
    if (roomEvent.result == SUCCESS)
    {
        RoomData *roomData = roomEvent.roomData;
        if(subscribed == NO){
            subscribed = YES;
            NSLog(@"SUBSCRIBE ROOM CALLED");
            [[WarpClient getInstance]subscribeRoom:roomData.roomId];
        }
        [[WarpClient getInstance]getLiveRoomInfo:roomData.roomId];
        [GameConstants setCurrentRoomId:roomData.roomId];
        NSLog(@".onJoinRoomDone..on Join room listener called Success");
    }
    else
    {
        NSLog(@".onJoinRoomDone..on Join room listener called failed");
        [[WarpClient getInstance] createRoomWithRoomName:[GameConstants getUserName] roomOwner:@"admin" properties:nil maxUsers:10];
    }
    
}

-(void)onLeaveRoomDone:(RoomEvent*)roomEvent{
    if (roomEvent.result == SUCCESS) {
        NSLog(@"Left Room");
        joined = NO;
        [[WarpClient getInstance]unsubscribeRoom:roomEvent.roomData.roomId];
        [[WarpClient getInstance] getLiveRoomInfo:roomEvent.roomData.roomId];
        [GameConstants setCurrentRoomId:nil];
    }
    else {
    }
}

-(void)onGetLiveRoomInfoDone:(LiveRoomInfoEvent*)event{
    NSString *joinedUsers = @"";
    NSLog(@"joined users array = %@",event.joinedUsers);
    
    //no one is in the room so kill it
    if([event.joinedUsers count] == 0){
        [[WarpClient getInstance] deleteRoom:event.roomData.roomId];
    }
    
    [[ViewController sharedViewController] updatePlayerList:event.joinedUsers];
    for (int i=0; i<[event.joinedUsers count]; i++)
    {
        joinedUsers = [joinedUsers stringByAppendingString:[event.joinedUsers objectAtIndex:i]];
        
    }
}

-(void)onSetCustomRoomDataDone:(LiveRoomInfoEvent*)event{
    NSLog(@"event joined users = %@",event.joinedUsers);
    NSLog(@"event custom data = %@",event.customData);

}

@end
