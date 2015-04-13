//
//  GameConstants.m
//  NetworkingDemo
//
//  Created by Kyle Bailey on 1/16/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//

#import "GameConstants.h"
@implementation GameConstants

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

NSString *handle = nil; //Used for login and high score information
NSString *userName = nil; //Used for appwarp communication
NSString *roomIdToJoin = nil;
NSString *currentRoomId = nil;
NSString *subscribedRoom = nil;

+(NSString *)getHandle
{
    return handle;
}

+(void)setHandle:(NSString *)inputHandle
{
    handle = inputHandle;
}

+(NSString *) getUserName
{
    
    if(userName == nil){
        NSMutableString *randomString = [NSMutableString stringWithCapacity: 10];
        
        for (int i=0; i<10; i++) {
            [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
        }
        
        userName = randomString;
    }
    
    return userName;
}

+(void) setUserName:(NSString *)inputuserName
{
    userName = inputuserName;
}

+(NSString *)getRoomIdToJoin
{
    return roomIdToJoin;
}

+(void)setRoomIdToJoin:(NSString *)roomId
{
    roomIdToJoin = roomId;
}

+(NSString *)getCurrentRoomId
{
    return currentRoomId;
}

+(void)setCurrentRoomId:(NSString *)roomId
{
    currentRoomId = roomId;
}

+(NSString *)getSubscribedRoom
{
    return subscribedRoom;
}

+(void)setSubscribedRoom:(NSString *)roomId
{
    subscribedRoom = roomId;
}

@end
