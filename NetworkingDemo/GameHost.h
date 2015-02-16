//
//  GameHost.h
//  WordPlay
//
//  Created by Kyle Bailey on 2/15/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppWarp_iOS_SDK/AppWarp_iOS_SDK.h>
#import <UIKit/UIKit.h>
@interface GameHost : NSObject

@property (strong, nonatomic) NSMutableDictionary *playerColors;
@property (strong, nonatomic) NSMutableArray *colorArray;

+(GameHost *)sharedGameHost;
-(void)addColorforPlayer:(NSString *)userName;
-(UIColor *)getColorForPlayer:(NSString *)userName;
-(void)setStartingWord:(NSString *)startingWord;
-(NSString *)getStartingWord;
-(void)overrideColor:(UIColor *)color forPlayer:(NSString *)userName;


@end