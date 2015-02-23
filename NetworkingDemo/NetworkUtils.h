//
//  NetworkUtils.h
//  NetworkingDemo
//
//  Created by Kyle Bailey on 1/16/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppWarp_iOS_SDK/AppWarp_iOS_SDK.h>
#import "ViewController.h"
#import "GameConstants.h"

@interface NetworkUtils : NSObject

+(void)sendLetterPlayed:(NSString *)update;
+(void)sendFinalLetterPlayed:(NSString *)update;
+(void)sendWordPlayed;
+(void)sendLetterFinalRemoved:(NSString *)update;
+(void)sendLetterRemoved:(NSString *)update;
+(void)sendJoinedLobby;
+(void)sendStartGame;
+(void)sendPlayerScore:(NSString *)score;
+(void)sendStartingWord:(NSString *)word;
+(void)sendUpdateColor:(NSString *)color forPlayer:(NSString *)player;
+(void)joinRoom;
+(void)createRoom;
+(void)sendLetterReturned:(NSString *)update;


@end
