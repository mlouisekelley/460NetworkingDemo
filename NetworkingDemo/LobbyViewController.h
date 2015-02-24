//
//  LobbyViewController.h
//  NetworkingDemo
//
//  Created by Kyle Bailey on 2/4/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LobbyViewController : UIViewController

+(LobbyViewController *)sharedViewController;
-(void)playerJoinedLobby;
-(void)startGame;
- (IBAction)playButtonTouched:(id)sender;

@end
