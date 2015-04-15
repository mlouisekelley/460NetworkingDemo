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
#import <Parse/Parse.h>

@interface LobbyViewController ()

@property (nonatomic) BOOL touchToPlay;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *waitingIndicator;
@property (strong, nonatomic) UIAlertController *loginOrSignup;

@end

@implementation LobbyViewController

static LobbyViewController *vc;
static bool joined = NO;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    joined = NO;
    self.touchToPlay = NO;
    vc = self;
    [self configureAppWarp];
    
    self.loginOrSignup = [UIAlertController
                          alertControllerWithTitle:@"Welcome!"
                          message:nil
                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *loginAction = [UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self.loginOrSignup dismissViewControllerAnimated:YES completion:nil];
        [self login];
    }];
    UIAlertAction *signupAction = [UIAlertAction actionWithTitle:@"Sign Up" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self.loginOrSignup dismissViewControllerAnimated:YES completion:nil];
        [self signUp];
    }];
    
    
    [self.loginOrSignup addAction:loginAction];
    [self.loginOrSignup addAction:signupAction];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self performLogin];
}

-(void)notConnectedToAppWarp
{
    NSString *message = [NSString stringWithFormat:@"Unable to connect to our server, please check your internet connection"];
    UIAlertController *notConnectedAlert=   [UIAlertController
                                     alertControllerWithTitle:@"No Connection"
                                     message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *retry = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [notConnectedAlert dismissViewControllerAnimated:YES completion:nil];
        [[WarpClient getInstance] connectWithUserName:[GameConstants getUserName]];
    }];
    
    [notConnectedAlert addAction:retry];
    [self presentViewController:notConnectedAlert animated:YES completion:nil];
}

- (void)performLogin {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        // do stuff with the user
        [GameConstants setHandle:currentUser.username];
        return;
    }
    
    
    [self presentViewController:self.loginOrSignup animated:YES completion:nil];
    
}

- (void) login {
    
    UIAlertController * userNameAlert = [UIAlertController
                                         alertControllerWithTitle:@"Login"
                                         message:@"Please enter player name and password"
                                         preferredStyle:UIAlertControllerStyleAlert];
    
    [userNameAlert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"username";
     }];
    
    [userNameAlert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"password";
         textField.secureTextEntry = YES;
     }];
    
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [userNameAlert dismissViewControllerAnimated:YES completion:nil];
                                 [self presentViewController:self.loginOrSignup animated:YES completion:nil];
                             }];
    
    //create ok action for alert
    UIAlertAction* okay = [UIAlertAction
                           actionWithTitle:@"Enter"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               //[userNameAlert dismissViewControllerAnimated:YES completion:nil];
                               UITextField *login = userNameAlert.textFields.firstObject;
                               UITextField *password = userNameAlert.textFields.lastObject;
                               
                               [PFUser logInWithUsernameInBackground:login.text password:password.text
                                                               block:^(PFUser *user, NSError *error) {
                                                                   if (user) {
                                                                       // Do stuff after successful login.
                                                                       [GameConstants setHandle:user.username];
                                                                   } else {
                                                                       // The login failed. Check error to see why.
                                                                       [userNameAlert dismissViewControllerAnimated:YES completion:nil];
                                                                       UIAlertController *errorController = [UIAlertController
                                                                                                             alertControllerWithTitle:@"Error"
                                                                                                             message:[error userInfo][@"error"]
                                                                                                             preferredStyle:UIAlertControllerStyleAlert];
                                                                       UIAlertAction *okAction = [UIAlertAction
                                                                                                  actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                                                                                  style:UIAlertActionStyleDefault
                                                                                                  handler:^(UIAlertAction *action)
                                                                                                  {
                                                                                                      [self presentViewController:userNameAlert animated:YES completion:nil];
                                                                                                  }];
                                                                       [errorController addAction:okAction];
                                                                       [self presentViewController:errorController animated:YES completion:nil];
                                                                   }
                                                               }];
                               
                           }];
    
    [userNameAlert addAction:cancel];
    [userNameAlert addAction:okay];
    
    [self presentViewController:userNameAlert animated:YES completion:nil];
    
}

- (void) signUp {
    UIAlertController * userNameAlert = [UIAlertController
                                         alertControllerWithTitle:@"Sign Up"
                                         message:@"Please enter player name and password you would like to register"
                                         preferredStyle:UIAlertControllerStyleAlert];
    
    [userNameAlert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"username";
     }];
    
    [userNameAlert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"password";
         textField.secureTextEntry = YES;
     }];
    
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [userNameAlert dismissViewControllerAnimated:YES completion:nil];
                                 [self presentViewController:self.loginOrSignup animated:YES completion:nil];
                             }];
    
    //create ok action for alert
    UIAlertAction* okay = [UIAlertAction
                           actionWithTitle:@"Enter"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               UITextField *login = userNameAlert.textFields.firstObject;
                               UITextField *password = userNameAlert.textFields.lastObject;
                               
                               PFUser *user = [PFUser user];
                               user.username = login.text;
                               user.password = password.text;
                               
                               [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                   if (!error) {
                                       // Hooray! Let them use the app now.
                                       [GameConstants setHandle:user.username];
                                       [userNameAlert dismissViewControllerAnimated:YES completion:nil];
                                       UIAlertController *success = [UIAlertController
                                                                             alertControllerWithTitle:@"Success!"
                                                                             message:@"Successfully created new user"
                                                                             preferredStyle:UIAlertControllerStyleAlert];
                                       UIAlertAction *okAction = [UIAlertAction
                                                                  actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                                                  style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action)
                                                                  {
                                                                      [success dismissViewControllerAnimated:YES completion:nil];
                                                                  }];
                                       [success addAction:okAction];
                                       [self presentViewController:success animated:YES completion:nil];
                                   } else {
                                       NSString *errorString = [error userInfo][@"error"];
                                       // Show the errorString somewhere and let the user try again.
                                       [userNameAlert dismissViewControllerAnimated:YES completion:nil];
                                       UIAlertController *errorController = [UIAlertController
                                                                             alertControllerWithTitle:@"Error"
                                                                             message:errorString
                                                                             preferredStyle:UIAlertControllerStyleAlert];
                                       UIAlertAction *okAction = [UIAlertAction
                                                                  actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                                                  style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action)
                                                                  {
                                                                      [self presentViewController:userNameAlert animated:YES completion:nil];
                                                                  }];
                                       [errorController addAction:okAction];
                                       [self presentViewController:errorController animated:YES completion:nil];
                                   }
                               }];
                           }];
    [userNameAlert addAction:cancel];
    [userNameAlert addAction:okay];
    [self presentViewController:userNameAlert animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createAndJoinGameWithName:(NSString *)name andNumPlayers:(int)players {
    numPlayers = players;
    [NetworkUtils createRoomWithName:name andNumPlayers:players];
    
    alertMessage = [NSString stringWithFormat:@"1/%d players have joined the room.", numPlayers];
    waitingForPlayersToJoinAlert=   [UIAlertController
                                     alertControllerWithTitle:@"Waiting..."
                                     message:alertMessage
                                     preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:waitingForPlayersToJoinAlert animated:YES completion:nil];
}

-(void)createSoloGame
{
    numPlayers = 1;
    [NetworkUtils createRoomWithName:[GameConstants getUserName] andNumPlayers:1];
}

-(void)joinExistingGame
{
    alertMessage = [NSString stringWithFormat:@"Waiting for host to start the game"];
    waitingForPlayersToJoinAlert=   [UIAlertController
                                     alertControllerWithTitle:@"Waiting..."
                                     message:alertMessage
                                     preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:waitingForPlayersToJoinAlert animated:YES completion:nil];
    [NetworkUtils joinRoom];
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
    NSLog(@"Player joined lobby message recieved");
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
    //[NetworkUtils deleteAllParseRoomInfo];
    UIAlertController *joinOrCreate = [UIAlertController
                                         alertControllerWithTitle:@"Select an option from below:"
                                         message:nil
                                         preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *joinAction = [UIAlertAction actionWithTitle:@"Join an exisiting game" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [joinOrCreate dismissViewControllerAnimated:YES completion:nil];
        [self goToJoinScreen];
    }];
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"Create a new game" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [joinOrCreate dismissViewControllerAnimated:YES completion:nil];
        [self createGame];
    }];
    UIAlertAction *soloAction = [UIAlertAction actionWithTitle:@"Play Solo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [joinOrCreate dismissViewControllerAnimated:YES completion:nil];
        [self createSoloGame];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [joinOrCreate dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [joinOrCreate addAction:joinAction];
    [joinOrCreate addAction:createAction];
    [joinOrCreate addAction:soloAction];
    [joinOrCreate addAction:cancelAction];
    
    [self presentViewController:joinOrCreate animated:YES completion:nil];
    
}

-(void)goToJoinScreen {
    [self configureAppWarp];
    [self showCurrentGames];

}

-(void)showCurrentGames
{
    UIAlertController * selectGameAlert = [UIAlertController
                                         alertControllerWithTitle:@"Open Games"
                                         message:@"Please select the game you wish to join"
                                         preferredStyle:UIAlertControllerStyleAlert];
    
    
    //Get currently available games to join from parse
    PFQuery *query = [PFQuery queryWithClassName:@"RoomData"];
    [query whereKey:@"numPlayers" greaterThan:@1];
    [query whereKey:@"gameStarted" equalTo:@NO];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu rooms.", (unsigned long)objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                UIAlertAction *gameAction = [UIAlertAction
                              actionWithTitle:object[@"name"]
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [selectGameAlert dismissViewControllerAnimated:YES completion:nil];
                                  [GameConstants setRoomIdToJoin:object[@"roomId"]];
                                  [self joinExistingGame];
                              }];
                [selectGameAlert addAction:gameAction];
            }
                UIAlertAction *cancel = [UIAlertAction
                                         actionWithTitle:@"Cancel"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             [selectGameAlert dismissViewControllerAnimated:YES completion:nil];
                                         }];
                [selectGameAlert addAction:cancel];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:selectGameAlert animated:YES completion:nil];
            });
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}
- (IBAction)logout:(id)sender {
    [PFUser logOut];
    [self presentViewController:self.loginOrSignup animated:YES completion:nil];
}

-(void)createGame {
    UIAlertController * roomNameAlert = [UIAlertController
                                         alertControllerWithTitle:@"Room Name"
                                         message:@"Please enter the display name for this room:"
                                         preferredStyle:UIAlertControllerStyleAlert];
    
    [roomNameAlert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"Room Name", @"Name");
     }];
    
    UIAlertAction *selectNumberOfPlayers = [UIAlertAction
                                            actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action)
                                            {
                                                UITextField *login = roomNameAlert.textFields.firstObject;
                                                NSString *gameName = login.text;
                                                //create an alert
                                                UIAlertController * alert=   [UIAlertController
                                                                              alertControllerWithTitle:@"Number of players"
                                                                              message:@"Choose how many players for this game"
                                                                              preferredStyle:UIAlertControllerStyleAlert];
                                                
                                                [self presentViewController:alert animated:YES completion:nil];
                                                
                                                //create ok action for alert
                                                UIAlertAction* p2 = [UIAlertAction
                                                                     actionWithTitle:@"2"
                                                                     style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action)
                                                                     {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                         [self createAndJoinGameWithName:gameName andNumPlayers:2];
                                                                     }];
                                                UIAlertAction* p3 = [UIAlertAction
                                                                     actionWithTitle:@"3"
                                                                     style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action)
                                                                     {
                                                                         
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                         [self createAndJoinGameWithName:gameName andNumPlayers:3];
                                                                     }];
                                                UIAlertAction* p4 = [UIAlertAction
                                                                     actionWithTitle:@"4"
                                                                     style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action)
                                                                     {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                         [self createAndJoinGameWithName:gameName andNumPlayers:4];
                                                                     }];
                                                
                                                UIAlertAction* cancel = [UIAlertAction
                                                                         actionWithTitle:@"Cancel"
                                                                         style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction * action)
                                                                         {
                                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                                             
                                                                         }];
                                                
                                                [alert addAction:p2]; // add action to uialertcontroller
                                                [alert addAction:p3]; // add action to uialertcontroller
                                                [alert addAction:p4]; // add action to uialertcontroller
                                                [alert addAction:cancel];
                                            }];
    
    
    [self presentViewController:roomNameAlert animated:YES completion:nil];
    [roomNameAlert addAction:selectNumberOfPlayers];
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
