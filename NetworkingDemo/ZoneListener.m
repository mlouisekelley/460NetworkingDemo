//
//  ZoneListener.m
//  WordPlay
//
//  Created by Kyle Bailey on 4/5/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//

#import "ZoneListener.h"
@implementation ZoneListener

@synthesize helper;

-(id)initWithHelper:(id)l_helper
{
    self.helper = l_helper;
    return self;
}

-(void)onGetAllRoomsDone:(AllRoomsEvent*)event
{
    
}

@end