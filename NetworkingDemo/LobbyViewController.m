//
//  LobbyViewController.m
//  NetworkingDemo
//
//  Created by Kyle Bailey on 2/4/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//

#import "LobbyViewController.h"
#import "GameConstants.h"
#import "RoomListener.h"
#import "NotificationListener.h"
#import "ConnectionListener.h"

@interface LobbyViewController ()

@end

@implementation LobbyViewController

static LobbyViewController *vc;
static bool joined = NO;
static bool first = YES;
static int numPlayers = 0;
static int joinsRecieved = 0;

+(LobbyViewController *)sharedViewController
{
    if(vc == nil)
    {
        vc = [[self alloc] init];
    }
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    joined = NO;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)playTwoPlayers:(id)sender {
    [sender setTitle:@"Waiting..." forState:UIControlStateNormal];
    [sender setEnabled:NO];
    
    numPlayers = 2;
    [self joinGame];
}

- (IBAction)playThreePlayers:(id)sender {
    [sender setTitle:@"Waiting..." forState:UIControlStateNormal];
    [sender setEnabled:NO];
    
    numPlayers = 3;
    [self joinGame];
}

-(void)joinGame {
    NSLog(@"HERE");
    vc = self;
    
    if(first){
        //appwarp configuration
        [WarpClient initWarp:APPWARP_APP_KEY secretKey: APPWARP_SECRET_KEY];
        
        WarpClient *warpClient = [WarpClient getInstance];
        [warpClient setRecoveryAllowance:60];
        [warpClient enableTrace:YES];
        
        ConnectionListener *connectionListener = [[ConnectionListener alloc] initWithHelper:self];
        [warpClient addConnectionRequestListener:connectionListener];
        [warpClient addZoneRequestListener:connectionListener];
        
        RoomListener *roomListener = [[RoomListener alloc]initWithHelper:self];
        [warpClient addRoomRequestListener:roomListener];
        
        NotificationListener *notificationListener = [[NotificationListener alloc]initWithHelper:self];
        [warpClient addNotificationListener:notificationListener];
        
        [warpClient connectWithUserName:[GameConstants getUserName]];
        first = NO;
    } else {
        [NetworkUtils sendJoinedGame];
    }
    
}

-(void)beginGame {
    if(joined){
        return;
    }
    joinsRecieved++;
    if(joinsRecieved + 1 == numPlayers){
        [vc performSegueWithIdentifier:@"BeginGame" sender:vc];
        [NetworkUtils sendJoinedGame];
        joined = YES;
    }
//    NSString * storyboardName = @"Main";
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
//    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"Test"];
//    [self presentViewController:vc animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
