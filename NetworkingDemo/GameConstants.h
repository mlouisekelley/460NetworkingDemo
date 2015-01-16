//
//  GameConstants.h
//  Cocos2DSimpleGame
//
//  Created by Rajeev on 25/01/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


#define APPWARP_APP_KEY     @"0e870a97a4690a79887457c63424cdaba52df6f1d04bdc6bcfea6e1b6944a996"
#define APPWARP_SECRET_KEY  @"0a9b21ad63eef6d793a247b61be5c1790c68882cb613b66fd2b3de73073c8300"
#define ROOM_ID             @"187591599"
//#define USER_NAME           @"userName"
#define DICTIONARY_KEY      @"414e9bf0-a284-4b40-9d99-2d339299a333"
#define TILE_WIDTH          32
#define STARTING_NUMBER_OF_TILES 7

#import <Foundation/Foundation.h>
#import <AppWarp_iOS_SDK/AppWarp_iOS_SDK.h>
@interface GameConstants : NSObject

+(NSString *)getUserName;

@end
