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
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *waitingIndicator;

@end

@implementation LobbyViewController

static LobbyViewController *vc;
static bool joined = NO;
static bool first = YES;
static int numPlayers = 0;
static int joinsRecieved = 0;
UIAlertController * waitingForPlayersToJoinAlert;
NSString *alertMessage;

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
    vc = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playOnePlayers:(id)sender {
    numPlayers = 1;
    [self joinGame];
}


- (IBAction)playTwoPlayers:(id)sender {
    numPlayers = 2;
    [self joinGame];
}

- (IBAction)playThreePlayers:(id)sender {
    numPlayers = 3;
    [self joinGame];
}

- (IBAction)playFourPlayers:(id)sender {
    numPlayers = 4;
    [self joinGame];
}

-(void)joinGame {
    alertMessage = [NSString stringWithFormat:@"1/%d players have joined the room.", numPlayers];
    waitingForPlayersToJoinAlert=   [UIAlertController
                                  alertControllerWithTitle:@"Waiting..."
                                  message:alertMessage
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:waitingForPlayersToJoinAlert animated:YES completion:nil];
    
    if(first){
        //appwarp configuration
        [self configureAppWarp];
        first = NO;
    } else {
        [NetworkUtils sendJoinedLobby];
    }
    
}

-(void)configureAppWarp {
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
    [[WarpClient getInstance] connectWithUserName:[GameConstants getUserName]];
}

-(void)playerJoinedLobby {
    if(joined){
        return;
    }
    joinsRecieved++;
    waitingForPlayersToJoinAlert.message = [NSString stringWithFormat:@"%d/%d players have joined the room.", joinsRecieved+1, numPlayers];
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
        [self.waitingIndicator stopAnimating];
        [self startGameHelper];
    }
}

-(void)startGameHelper {
    [NetworkUtils generateAndSendStartingWord];
    if(numPlayers == 1){
        [self startGame];
    } else {
        [NetworkUtils sendStartGame];
    }
}

-(void)startGame {
    [vc performSegueWithIdentifier:@"BeginGame" sender:vc];
}

- (IBAction)playButtonTouched:(id)sender {
    UIAlertController *joinOrCreate = [UIAlertController
                                         alertControllerWithTitle:@"Do you want to join or create a game?"
                                         message:nil
                                         preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *joinAction = [UIAlertAction actionWithTitle:@"Join" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [joinOrCreate dismissViewControllerAnimated:YES completion:nil];
        [self goToJoinScreen];
    }];
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [joinOrCreate dismissViewControllerAnimated:YES completion:nil];
        [self createGame];
    }];
    
    [joinOrCreate addAction:joinAction];
    [joinOrCreate addAction:createAction];
    
    [self presentViewController:joinOrCreate animated:YES completion:nil];
    
}

-(void)goToJoinScreen {
    [self configureAppWarp];
    UIAlertController * userNameAlert = [UIAlertController
                                         alertControllerWithTitle:@"Username"
                                         message:@"Please enter player name"
                                         preferredStyle:UIAlertControllerStyleAlert];
    
    [userNameAlert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"LoginPlaceholder", @"Name");
     }];
    
    //create ok action for alert
    UIAlertAction* okay = [UIAlertAction
                           actionWithTitle:@"Enter"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               //[userNameAlert dismissViewControllerAnimated:YES completion:nil];
                               [[WarpClient getInstance] getAllRooms];
                           }];
    
    [userNameAlert addAction:okay];
    [self presentViewController:userNameAlert animated:YES completion:nil];
}

-(void)showCurrentGames:(NSMutableArray *)roomIds
{
    UIAlertController * selectGameAlert = [UIAlertController
                                         alertControllerWithTitle:@"Open Games"
                                         message:@"Please select the game you wish to join"
                                         preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction*  gameAction;
    for (NSString *roomId in roomIds) {
        gameAction = [UIAlertAction
                             actionWithTitle:roomId
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [selectGameAlert dismissViewControllerAnimated:YES completion:nil];
                                 [GameConstants setRoomIdToJoin:roomId];
                                 [self playFourPlayers:gameAction];
                             }];
        [selectGameAlert addAction:gameAction];
    }
    
    [self presentViewController:selectGameAlert animated:YES completion:nil];
}

-(void)createGame {
    UIAlertController * userNameAlert = [UIAlertController
                                         alertControllerWithTitle:@"Username"
                                         message:@"Please enter player name"
                                         preferredStyle:UIAlertControllerStyleAlert];
    
    [userNameAlert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"LoginPlaceholder", @"Name");
     }];
    
    UIAlertAction *selectNumberOfPlayers = [UIAlertAction
                                            actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action)
                                            {
                                                UITextField *login = userNameAlert.textFields.firstObject;
                                                [GameConstants setUserName:login.text];
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
                                                
                                                UIAlertAction* cancel = [UIAlertAction
                                                                         actionWithTitle:@"Cancel"
                                                                         style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction * action)
                                                                         {
                                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                                             
                                                                         }];
                                                
                                                [alert addAction:p1]; // add action to uialertcontroller
                                                [alert addAction:p2]; // add action to uialertcontroller
                                                [alert addAction:p3]; // add action to uialertcontroller
                                                [alert addAction:p4]; // add action to uialertcontroller
                                                [alert addAction:cancel];
                                            }];
    
    
    [self presentViewController:userNameAlert animated:YES completion:nil];
    [userNameAlert addAction:selectNumberOfPlayers];
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
        vc.numPlayers = numPlayers;
    }
    if ([[segue identifier] isEqualToString:@"JoinGame"])
    {
        NSLog(@"JoinGame Seque was called");
    }
}


@end
