//
//  ConnectionListener.m
//  Cocos2DSimpleGame
//
//  Created by Rajeev on 23/01/13.
//
//

#import "ConnectionListener.h"
#import "LobbyViewController.h"
#import <Parse/Parse.h>
@implementation ConnectionListener
@synthesize helper;

-(id)initWithHelper:(id)l_helper
{
    self.helper = l_helper;
    return self;
}

-(void)onConnectDone:(ConnectEvent*) event
{
    //NSLog(@"%s...name=%@",__FUNCTION__,[helper userName]);
    if (event.result==SUCCESS)
    {
        NSLog(@"connection success");
        //USE THIS TO CLEAR APP WARP ROOMS:
        //[NetworkUtils deleteAllAppWarpRooms];
    }
    else if (event.result==SUCCESS_RECOVERED)
    {
        NSLog(@"connection recovered");
    }
    else if (event.result==CONNECTION_ERROR_RECOVERABLE)
    {
        NSLog(@"recoverable connection error");
        
    }
    else if (event.result==BAD_REQUEST)
    {
        
        NSLog(@"Bad request");
    }
    else
    {
        NSLog(@"Disconnected");
        [[LobbyViewController sharedViewController] notConnectedToAppWarp];
    }
}



-(void)onJoinZoneDone:(ConnectEvent*) event
{
    if (event.result==0)
    {
        NSLog(@"Join Zone done");
        
        //[[WarpClient getInstance] joinRoom:[[AppWarpHelper sharedAppWarpHelper] roomId]];
    }
    else
    {
        NSLog(@"Join Zone failed");
    }

}


-(void)onAuthenticationDone:(ConnectEvent*) event
{
    if(event.result == SUCCESS)
    {
        NSLog(@"I am authenticated");
    }
}

-(void)onDisconnectDone:(ConnectEvent*) event{
    NSLog(@"On Disconnect invoked");
}

-(void)onGetMatchedRoomsDone:(MatchedRoomsEvent *)event
{
    
}

#pragma mark ------
#pragma mark ZoneListener Protocol methods

-(void)onGetAllRoomsDone:(AllRoomsEvent*)event{
    if (event.result == SUCCESS) {
        NSLog(@"Got all rooms");
        for(NSString *roomId in event.roomIds){
            [[WarpClient getInstance] deleteRoom:roomId];
        }
    }
    else {
        NSLog(@"Failed to get all rooms");
    }
}
-(void)onGetOnlineUsersDone:(AllUsersEvent*)event{
    if (event.result == SUCCESS)
    {
        //NSLog(@"usernames = %@",event.userNames);
//        int userCount = [event.userNames count];
//        [[AppWarpHelper sharedAppWarpHelper] setNumberOfPlayers:userCount];
//        if (userCount==2)
//        {
//            
//        }
    }
    else 
    {
        
    }
    
}
-(void)onGetLiveUserInfoDone:(LiveUserInfoEvent*)event{
    NSLog(@"onGetLiveUserInfo called");
    if (event.result == SUCCESS)
    {
        //[[WarpClient getInstance]setCustomUserData:event.name customData:usernameTextField.text];
    }
    else {
    }
    
}
-(void)onSetCustomUserDataDone:(LiveUserInfoEvent*)event{
    if (event.result == SUCCESS) {
    }
    else {
    }
}

-(void)onCreateRoomDone:(RoomEvent *)roomEvent{
    if(roomEvent.result == SUCCESS){
        NSLog(@"ROOM CREATED: %@", roomEvent.roomData.roomId);
        [[WarpClient getInstance] joinRoom:roomEvent.roomData.roomId];
        
        //Add game info to parse
        PFObject *room = [PFObject objectWithClassName:@"RoomData"];
        room[@"roomId"] = roomEvent.roomData.roomId;
        room[@"name"] = roomEvent.roomData.name;
        room[@"numPlayers"] = [NSNumber numberWithInt:roomEvent.roomData.maxUsers];
        room[@"gameStarted"] = @NO;
        for(int i = 0; i < 100; i++){
            NSString *roomKey = [NSString stringWithFormat:@"s%d", i];
            room[roomKey] = @0;
        }
        [room saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Parse saved room information");
            } else {
                NSLog(@"Parse save of room info failed");
            }
        }];
    } else {
        NSLog(@"failed to create room");
    }
}


-(void)onDeleteRoomDone:(RoomEvent *)roomEvent{
    if(roomEvent.result == SUCCESS){
        NSLog(@"Deleted room: %@", roomEvent.roomData.roomId);
        
        //delete the room from parse
        PFQuery *query = [PFQuery queryWithClassName:@"RoomData"];
        [query whereKey:@"roomId" equalTo:roomEvent.roomData.roomId];
        // Retrieve the object by id
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for (PFObject *object in objects) {
                [object deleteInBackground];
            }
        }];
    } else {
        NSLog(@"Failed to delete room: %@", roomEvent.roomData.roomId);
    }
}

@end
