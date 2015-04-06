//
//  JoinGameVC.m
//  WordPlay
//
//  Created by Kyle Bailey on 4/5/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//

#import "JoinGameVC.h"
#import "GameConstants.h"
#import "RoomListener.h"
#import "NotificationListener.h"
#import "ConnectionListener.h"

@interface JoinGameVC ()

@end

@implementation JoinGameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[WarpClient getInstance] getAllRooms];
}



@end
