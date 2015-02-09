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

@interface NetworkUtils : NSObject

+(void)sendLetterPlayed:(NSString *)update;
+(void)sendWordPlayed;
+(void)sendLetterRemoved:(NSString *)update;
+(void)sendJoinedGame;
+(void)sendPlayerScore:(NSString *)score;

@end
