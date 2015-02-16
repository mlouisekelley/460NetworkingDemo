//
//  GameHost.m
//  WordPlay
//
//  Created by Kyle Bailey on 2/15/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//

#import "GameHost.h"

@interface GameHost ()

@property (strong, nonatomic) NSString *startingWord;

@end

@implementation GameHost

static GameHost *gh;

-(void)addColorforPlayer:(NSString *)userName {
    if([self.playerColors objectForKey:userName]){
        return;
    }
    UIColor *color = [self.colorArray objectAtIndex:0];
    [self.colorArray removeObjectAtIndex:0];
    [self.playerColors setObject:color forKey:userName];
}

-(void)overrideColor:(UIColor *)color forPlayer:(NSString *)userName {
    [self.playerColors setObject:color forKey:userName];
}

-(UIColor *)getColorForPlayer:(NSString *)userName {
    return [self.playerColors objectForKey:userName];
}

-(void)setStartingWord:(NSString *)startingWord {
    _startingWord = startingWord;
}

-(NSString *)getStartingWord {
    return self.startingWord;
}

+(GameHost *)sharedGameHost
{
    if(gh == nil){
        gh = [[self alloc] init];
        gh.playerColors = [[NSMutableDictionary alloc] init];
        gh.colorArray = [[NSMutableArray alloc] initWithObjects:[UIColor orangeColor],[UIColor purpleColor],[UIColor greenColor],[UIColor blueColor], nil];
    }
    return gh;
}

@end