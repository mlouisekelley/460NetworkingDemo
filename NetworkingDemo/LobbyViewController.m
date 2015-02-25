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

@property (nonatomic) BOOL touchToPlay;

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

-(int)getNumPlayers {
    return numPlayers;
}

- (IBAction)switchStateChanged:(UISwitch *)switchState{
    if ([switchState isOn]) {
        self.touchToPlay = YES;
    } else {
        self.touchToPlay = NO;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    joined = NO;
    self.touchToPlay = NO;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playOnePlayers:(id)sender {
    [sender setTitle:@"Waiting..." forState:UIControlStateNormal];
    [sender setEnabled:NO];
    
    numPlayers = 1;
    [self joinGame];
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

- (IBAction)playFourPlayers:(id)sender {
    [sender setTitle:@"Waiting..." forState:UIControlStateNormal];
    [sender setEnabled:NO];
    
    numPlayers = 4;
    [self joinGame];
}

-(void)joinGame {
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
        [NetworkUtils sendJoinedLobby];
    }
    
}

-(void)playerJoinedLobby {
    if(joined){
        return;
    }
    joinsRecieved++;
    if(joinsRecieved + 1 == numPlayers){
        joined = YES;
        NSMutableDictionary *colors = [[GameHost sharedGameHost] playerColors];
        for (NSString *key in colors) {
            UIColor *color = [colors objectForKey:key];
            if([color isEqual:[UIColor orangeColor]]){
                [NetworkUtils sendUpdateColor:@"orange" forPlayer:key];
            }
            if([color isEqual:[UIColor purpleColor]]){
                [NetworkUtils sendUpdateColor:@"purple" forPlayer:key];
            }
            if([color isEqual:[UIColor greenColor]]){
                [NetworkUtils sendUpdateColor:@"green" forPlayer:key];
            }
            if([color isEqual:[UIColor blueColor]]){
                [NetworkUtils sendUpdateColor:@"blue" forPlayer:key];
            }
        }
        [self startGameHelper];
    }
}

-(void)startGameHelper {
    NSArray *starting_words = @[@"START", @"WORDS", @"PLAY", @"BEGIN"];
    NSString *starting_word = [starting_words objectAtIndex: arc4random() % [starting_words count]];
    [NetworkUtils sendStartingWord:starting_word];
    [NetworkUtils sendStartGame];
}

-(void)startGame {
    [vc performSegueWithIdentifier:@"BeginGame" sender:vc];
}

- (IBAction)playButtonTouched:(id)sender {
    //create an alert
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Number of players"
                                  message:@"Choose how many players there are"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    //create ok action for alert
    UIAlertAction* p1 = [UIAlertAction
                         actionWithTitle:@"1"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             [self playOnePlayers:p1];
                         }];
    UIAlertAction* p2 = [UIAlertAction
                         actionWithTitle:@"2"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             [self playTwoPlayers:p2];
                         }];
    UIAlertAction* p3 = [UIAlertAction
                         actionWithTitle:@"3"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             [self playThreePlayers:p3];
                         }];
    UIAlertAction* p4 = [UIAlertAction
                         actionWithTitle:@"4"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             [self playFourPlayers:p4];
                         }];
    
    [alert addAction:p1]; // add action to uialertcontroller
    [alert addAction:p2]; // add action to uialertcontroller
    [alert addAction:p3]; // add action to uialertcontroller
    [alert addAction:p4]; // add action to uialertcontroller
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"BeginGame"])
    {
        // Get reference to the destination view controller
        ViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        vc.touchToPlay = self.touchToPlay;
    }
}


@end
