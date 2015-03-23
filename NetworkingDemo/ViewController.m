//
//  ViewController.m
//  NetworkingDemo
//
//  Created by Margaret Kelley on 12/25/14.
//  Copyright (c) 2014 Margaret Kelley. All rights reserved.
//

#import "ViewController.h"
#import "BoardViewCell.h"
#import "GameConstants.h"
#import "GameHost.h"
#import "BoardChecker.h"
#import "BoardCellDTO.h"
#import "Player.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioPlayer.h>

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate>

@property (strong, nonatomic) NSMutableArray *board;
@property (strong, nonatomic) NSMutableArray *tileSpaces;
@property (nonatomic) NSInteger selectedIndex;
@property (strong, nonatomic) CADisplayLink *displayLink;
@property (strong, nonatomic) NSTimer *scoreTimer;
@property (strong, nonatomic) NSMutableArray *players;
@property (strong, nonatomic) NSMutableDictionary *playerScores;
@property (strong, nonatomic) NSMutableArray *allTiles;
@property (strong, nonatomic) TileViewCell *selectedTile;
@property (strong, nonatomic) BoardChecker *boardChecker;
@property (strong, nonatomic) NSDictionary *stringToColor;
@property (strong, nonatomic) NSMutableDictionary *playerColors;
@property (strong, nonatomic) NSMutableArray* startingWordTiles;
@property (strong, nonatomic) NSMutableArray *rackTileFrames;
@end

@implementation ViewController

static ViewController *vc;
Player *currentPlayer;
int minutes;
int seconds;
int milliseconds;
BOOL isGameOver = NO;
int TILE_WIDTH;
int TILE_HEIGHT;
int displayScore = 0;
int playerTwoScore = 0;
int playerThreeScore = 0;
int playerFourScore = 0;
double frameTimestamp;
int playerNumber = 2;
NSString *successNoisePath;
NSURL *successNoisePathURL;
int waitsRecieved = 0;
UIAlertController * waitingAlert;

- (void)viewDidLoad {
    
    isGameOver = NO;
    
    [super viewDidLoad];
    [self.boardCollectionView setTag:1];
    
    [self.boardCollectionView reloadData];
    self.boardCollectionView.dataSource = self;
    self.boardCollectionView.delegate = self;
    self.boardCollectionView.minimumZoomScale = .01;
    self.boardCollectionView.zoomScale = 10;
    
    vc = self;
    currentPlayer = [[Player alloc] init];
    currentPlayer.userName = [GameConstants getUserName];
    currentPlayer.playerNumber = 1;
    currentPlayer.color = [[GameHost sharedGameHost] getColorForPlayer:currentPlayer.userName];
    self.currentPlayerScoreLabel.textColor = currentPlayer.color;
    _allTiles = [[NSMutableArray alloc] init];
    
    successNoisePath  = [[NSBundle mainBundle] pathForResource:@"success" ofType:@"m4a"];
    successNoisePathURL = [NSURL fileURLWithPath : successNoisePath];
    
    
    _scoreTimer = [NSTimer scheduledTimerWithTimeInterval:0.04f target:self selector:@selector(updateScoreDisplay:) userInfo:nil repeats:YES];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.bkgView addGestureRecognizer:tapGesture];

//    [self.barTimerViewBoarder.layer setBorderColor: [[UIColor blackColor] CGColor]];
//    [self.barTimerViewBoarder.layer setBorderWidth: 2.0];
}

-(void) setUpGame {
    minutes = 2;
    seconds = 0;
    milliseconds = 0;
    
    playerTwoScore = 0;
    playerThreeScore = 0;
    playerFourScore = 0;
    
    currentPlayer.numberOfTiles = 0;
    frameTimestamp = CACurrentMediaTime();
    
    _tileSpaces = [[NSMutableArray alloc] init];

    self.startingWordTiles = [[NSMutableArray alloc] init];

    for (TileViewCell *cell in self.allTiles) {
        if(![cell isStartingTile]){
           [cell removeFromSuperview];
        } else {
            [cell removeFromSuperview];
            [self.startingWordTiles addObject:cell];
        }
    }
    [self resetScores];
    
    [self resetBoard];
    [self.boardCollectionView reloadData];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setUpGame];
    
}
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    for (int i = 0; i < STARTING_NUMBER_OF_TILES; i++) {
        CGRect rec = CGRectMake(i * (TILE_WIDTH + 30) + self.boardCollectionView.frame.origin.x, self.boardCollectionView.frame.origin.y + (self.boardCollectionView.bounds.size.height + 40), TILE_WIDTH, TILE_HEIGHT);
        [self.tileSpaces addObject:[NSValue valueWithCGRect:rec]];
        [self.rackTileFrames addObject:[NSValue valueWithCGRect:rec]];
        [self createTileInRack];
    }
    [self placeStartingWord];
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateCounter:)];
    
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];

}

-(void)resetBoard {
    _board = [[NSMutableArray alloc] init];
    for (int i = 0; i < 10; i++) {
        for (int j = 0; j < 10; j++) {
            BoardCellDTO *cell = [[BoardCellDTO alloc] init];
            cell.isPending = 0;
            [_board addObject:cell];
            cell.tvc = nil;
        }
    }
}

#pragma mark Lazy Instantiations

- (NSMutableArray *)rackTileFrames {
    if (!_rackTileFrames) {
        _rackTileFrames = [[NSMutableArray alloc] init];
    }
    return _rackTileFrames;
}


- (NSMutableDictionary *)playerScores {
    if (!_playerScores) {
        _playerScores = [[NSMutableDictionary alloc] init];
    }
    return _playerScores;
}

- (NSDictionary *)stringToColor {
    if (!_stringToColor) {
        _stringToColor = @{@"blue": [UIColor blueColor], @"orange": [UIColor orangeColor]};
    }
    return _stringToColor;
}

- (NSMutableDictionary *)playerColors {
    if (!_playerColors) {
        _playerColors = [[NSMutableDictionary alloc] init];
    }
    return _playerColors;
}

- (BoardChecker *) boardChecker {
    if (!_boardChecker) {
        _boardChecker = [[BoardChecker alloc] initWithScrabbleDict];
    }
    return _boardChecker;
}

+(ViewController *)sharedViewController
{
    if(vc == nil)
    {
        vc = [[self alloc] init];
    }
    return vc;
}

- (NSMutableArray *)board
{
    if (!_board) {
        _board = [[NSMutableArray alloc] init];
        for (int i = 0; i < 10; i++) {
            for (int j = 0; j < 10; j++) {
                BoardCellDTO *cell = [[BoardCellDTO alloc] init];
                cell.tvc = nil;
                cell.isPending = 0;
                [_board addObject:cell];
            }
        }
    }
    return _board;
}

- (NSArray *)tileSpaces
{
    if (!_tileSpaces) {
        _tileSpaces = [[NSMutableArray alloc] init];
    }
    return _tileSpaces;
}

- (NSMutableArray *)players {
    if (!_players) {
        _players = [[NSMutableArray alloc] init];
        [_players addObject:currentPlayer];
    }
    return _players;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Methods For Touch and Tap Type of Playing Tiles

-(BOOL)tileIsSelected {
    if(!_selectedTile){
        return false;
    }
    return true;
}

-(void)setSelectedTile:(TileViewCell *)tile
{
    _selectedTile = tile;
    [tile makeSelected];
}

-(void)clearSelectedTile
{
    if(_selectedTile){
        [_selectedTile makeUnselected];
    }
    _selectedTile = nil;
}

- (IBAction)togglePlayStyle:(id)sender {
    if(_touchToPlay){
        _touchToPlay = false;
    } else {
        _touchToPlay = true;
    }
    
    if(_selectedTile){
        [_selectedTile makeUnselected];
    }
}

#pragma mark End Game stuff
- (void)updateCounter:(CADisplayLink *)displayLink {
    double currentTime = [displayLink timestamp];
    double timeSince = currentTime - frameTimestamp;
    frameTimestamp = currentTime;
    
    if (!isGameOver) {
        int mil = 1000 * (timeSince - floor(timeSince));
        int sec = floor(timeSince);
        
        milliseconds -= mil;
        
        if (milliseconds < 0) {
            seconds += -1 + (milliseconds / 1000);
            milliseconds = 1000 + milliseconds % 1000;
        }
        
        seconds -= sec;
        if (seconds < 0) {
            minutes += -1 + (seconds / 60) ;
            seconds = 60 + seconds % 60;
        }
        
        if (sec > 60) {
            minutes-= sec / 60;
            sec = sec % 60;
        }
        
        
        if (seconds <= 5 && minutes == 0) {
            self.countDownLabel.text = [NSString stringWithFormat:@"%d", seconds];
            self.countDownLabel.alpha = 0.5 * (milliseconds) / 1000.0 + .2;
        }
        else {
            self.countDownLabel.text = @"";
        }
        
        if (minutes < 0  && !isGameOver) {
            [self gameOver];
        }
        self.msLabel.text = [NSString stringWithFormat:@"%d",milliseconds / 10];
        self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];

        double percent = (minutes * 60.0 * 1000 + seconds * 1000 + milliseconds) / (180 * 1000.0);
//        self.circleTimerView.percent = percent;
//        self.circleTimerView.seconds = seconds + minutes * 60;
//        self.circleTimerView.milliseconds = milliseconds;
//        [self.circleTimerView setNeedsDisplay];
        self.barTimerView.percent = percent;
        [self.barTimerView setNeedsDisplay];
        
//        [self.view bringSubviewToFront:self.circleTimerView];
    }
}

- (void)updateScoreDisplay:(NSTimer *)theTimer {
    if (displayScore < currentPlayer.score) {
        int incAmnt = (currentPlayer.score - displayScore) / 9 + 1;
        if (displayScore + incAmnt > currentPlayer.score) {
            displayScore = currentPlayer.score;
        }
        else {
            displayScore += incAmnt;
        }
    }
    else {
        displayScore = currentPlayer.score;
    }
    self.currentPlayerScoreLabel.text = [NSString stringWithFormat:@"%d", displayScore];
    if ([self isCurrentWinner:currentPlayer]) {
        [self.p1TrophyImageView setImage:[UIImage imageNamed:@"Trophy"]];
        [self.p2TrophyImageView setImage:[UIImage imageNamed:@"Trophy2"]];
        [self.p3TrophyImageView setImage:[UIImage imageNamed:@"Trophy2"]];
        [self.p4TrophyImageView setImage:[UIImage imageNamed:@"Trophy2"]];
    }
    [self updateEnemyScores];
}

-(BOOL) isCurrentWinner:(Player *)player {
    Player* maxPlayer = [self getMaxPlayer];
    if (maxPlayer.playerNumber == player.playerNumber) {
        return YES;
    }
    return NO;
}

-(void)updateEnemyScores{
    for(Player *player in [self players]){
        
        //red player
        if(player.playerNumber == 2){
            if (playerTwoScore < player.score) {
                int incAmnt = (player.score - playerTwoScore) / 9 + 1;
                if (playerTwoScore + incAmnt > player.score) {
                    playerTwoScore = player.score;
                }
                else {
                    playerTwoScore += incAmnt;
                }
            }
            else {
                playerTwoScore = player.score;
            }
            self.playerTwoScoreLabel.textColor = player.color;
            self.playerTwoScoreLabel.text = [NSString stringWithFormat:@"%d", playerTwoScore];
            
            if ([self isCurrentWinner:player]) {
                [self.p1TrophyImageView setImage:[UIImage imageNamed:@"Trophy2"]];
                [self.p2TrophyImageView setImage:[UIImage imageNamed:@"Trophy"]];
                [self.p3TrophyImageView setImage:[UIImage imageNamed:@"Trophy2"]];
                [self.p4TrophyImageView setImage:[UIImage imageNamed:@"Trophy2"]];
            }
        }
        
        //blue player
        if(player.playerNumber == 3){
            if (playerThreeScore < player.score) {
                int incAmnt = (player.score - playerThreeScore) / 9 + 1;
                if (playerThreeScore + incAmnt > player.score) {
                    playerThreeScore = player.score;
                }
                else {
                    playerThreeScore += incAmnt;
                }
            }
            else {
                playerThreeScore = player.score;
            }
            self.playerThreeScoreLabel.textColor = player.color;
            self.playerThreeScoreLabel.text = [NSString stringWithFormat:@"%d", playerThreeScore];
            if ([self isCurrentWinner:player]) {
                [self.p1TrophyImageView setImage:[UIImage imageNamed:@"Trophy2"]];
                [self.p2TrophyImageView setImage:[UIImage imageNamed:@"Trophy2"]];
                [self.p3TrophyImageView setImage:[UIImage imageNamed:@"Trophy"]];
                [self.p4TrophyImageView setImage:[UIImage imageNamed:@"Trophy2"]];
            }

        }
        
        //purple player
        if(player.playerNumber == 4){
            if (playerFourScore < player.score) {
                int incAmnt = (player.score - playerFourScore) / 9 + 1;
                if (playerFourScore + incAmnt > player.score) {
                    playerFourScore = player.score;
                }
                else {
                    playerFourScore += incAmnt;
                }
            }
            else {
                playerFourScore = player.score;
            }
            self.playerFourScoreLabel.textColor = player.color;
            self.playerFourScoreLabel.text = [NSString stringWithFormat:@"%d", playerFourScore];
            if ([self isCurrentWinner:player]) {
                [self.p1TrophyImageView setImage:[UIImage imageNamed:@"Trophy2"]];
                [self.p2TrophyImageView setImage:[UIImage imageNamed:@"Trophy2"]];
                [self.p3TrophyImageView setImage:[UIImage imageNamed:@"Trophy2"]];
                [self.p4TrophyImageView setImage:[UIImage imageNamed:@"Trophy"]];
            }

        }
    }
}


-(void) gameOver {
    isGameOver = YES;
    NSString *alertMessage = @"";
    
    if ([self didCurrentPlayerWin]) {
        alertMessage = @"You Win!";
    }
    else {
        alertMessage = @"You Lose.";
    }
    
    if (objc_getClass("UIAlertController") != nil){
        
        //create an alert
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"GAME OVER"
                                      message:alertMessage
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        //create rematch action for alert
        UIAlertAction* rematch = [UIAlertAction
                             actionWithTitle:@"Rematch!"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                                 [NetworkUtils sendWaitingForRematch];
                                 
                                 waitingAlert=   [UIAlertController
                                                               alertControllerWithTitle:@"WAITING"
                                                               message:alertMessage
                                                               preferredStyle:UIAlertControllerStyleAlert];
                                 
                                 [self presentViewController:waitingAlert animated:YES completion:nil];
                             }];
        
        //create ok action for alert
        UIAlertAction* home = [UIAlertAction
                             actionWithTitle:@"Home"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                                 [NetworkUtils sendWaitingForRematch];
                                 
                                 [vc performSegueWithIdentifier:@"ReturnToLobby" sender:vc];
                             }];
        
        [alert addAction:home];
        [alert addAction:rematch]; // add action to uialertcontroller
        
    }
    else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Board" message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
}

-(Player *)getMaxPlayer {
    Player *maxPlayer = nil;
    for (Player *player in self.players) {
        if (maxPlayer == nil || maxPlayer.score < player.score) {
            maxPlayer = player;
        }
    }
    return maxPlayer;
}

-(BOOL) didCurrentPlayerWin {
    Player *maxPlayer = [self getMaxPlayer];
    if([maxPlayer.userName isEqualToString:[GameConstants getUserName]]){
        return YES;
    }
    return NO;
}

-(void)restart {
    [waitingAlert dismissViewControllerAnimated:YES completion:nil];
    waitsRecieved = 0;
    isGameOver = NO;
    [self setUpGame];
    for (int i = 0; i < STARTING_NUMBER_OF_TILES; i++) {
        CGRect rec = CGRectMake(i * (TILE_WIDTH + 30) + self.boardCollectionView.frame.origin.x + 15, self.boardCollectionView.frame.origin.y + (self.boardCollectionView.bounds.size.height + 40), TILE_WIDTH, TILE_HEIGHT);
        [self.tileSpaces addObject:[NSValue valueWithCGRect:rec]];
        [self createTileInRack];
    }
    [self placeStartingWord];
    [self clearScores];
}

-(void)playerWaitingForRematch {
    waitsRecieved++;
    if(waitsRecieved == _numPlayers){
        [NetworkUtils generateAndSendStartingWord];
        [NetworkUtils sendStartRematch];
    }
}

-(void)rematch {
    [self restart];
}

-(void)clearScores{
    displayScore = 0;
    playerTwoScore = 0;
    playerThreeScore = 0;
    playerFourScore = 0;
    
    for(Player *player in [self players]){
        player.score = 0;
        if(player.playerNumber == 2){
            self.playerTwoScoreLabel.text = 0;
        }
        if(player.playerNumber == 3){
            self.playerThreeScoreLabel.text = 0;
        }
        if(player.playerNumber == 4){
            self.playerFourScoreLabel.text = 0;
        }
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
      return 100;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    if (collectionView.tag == 1) {
        //use self.board to determine how the board looks
        BoardViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"board cell" forIndexPath:indexPath];
        
        NSString *text = @"";
        BoardCellDTO *dto = (BoardCellDTO *)self.board[indexPath.item];
        dto.cell = cell;
        if (dto.isPending > 0) {
            cell.backgroundColor = dto.player.color;
            if (cell.backgroundColor == [UIColor orangeColor] ) {
                [cell.tempImgView setImage:[UIImage imageNamed:@"Unplayed1"]];
            }
            else if (cell.backgroundColor == [UIColor purpleColor] ) {
                [cell.tempImgView setImage:[UIImage imageNamed:@"Unplayed2"]];
            }
            else if (cell.backgroundColor == [UIColor greenColor] ) {
                [cell.tempImgView setImage:[UIImage imageNamed:@"Unplayed3"]];
            }
            else if (cell.backgroundColor == [UIColor blueColor] ) {
                [cell.tempImgView setImage:[UIImage imageNamed:@"Unplayed4"]];
            }
        }
        else {
                [cell.tempImgView setImage:[UIImage imageNamed:@"EmptyCell"]];

            cell.backgroundColor = [UIColor lightGrayColor];
        }
        cell.layer.borderWidth=2.0f;
        
        cell.layer.borderColor=[UIColor blackColor].CGColor;
        cell.textLabel.text = text;
        cell.textLabel.textColor = [UIColor whiteColor];
    
        return cell;
//    }
    
//    return nil;
}

#pragma mark - touch controller methods
-(void)boardWasTouched:(UITouch *)touch {
    CGPoint someLocation = [touch locationInView: self.view];
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(someLocation.x - TILE_WIDTH / 2.0, someLocation.y - TILE_HEIGHT/2.0, TILE_WIDTH, TILE_HEIGHT)];
    BoardViewCell *cell = [self findClosestCellToView:tempView];
    if(!cell){
        NSLog(@"CELL IS NIL");
    }
    
    NSIndexPath *indexPath = [self.boardCollectionView indexPathForCell:cell];
    
    if(_touchToPlay){
        if([self tileIsSelected]){
            [self playTile:_selectedTile atIndexPath:indexPath onCell:cell];
            [_selectedTile makeUnselected];
            _selectedTile = nil;
        }
    }
    
}

-(void)tileDidMove:(UIView *)tile {
    [self unhighlightAllCells];
    BoardViewCell *closestCell = [self findClosestCellToView:tile];
    if (closestCell != nil) {
        [self highlightCell:closestCell];
    }
}

-(BOOL) tileDidFinishMoving:(UIView *)tile {
    [self unhighlightAllCells];
    BoardViewCell *closestCell = [self findClosestCellToView:tile];
    TileViewCell *tileCell = (TileViewCell *)tile;
    if (closestCell) {
        closestCell.tag = 1;
        return [self playTile:tileCell atIndexPath:[_boardCollectionView indexPathForCell:closestCell] onCell:closestCell];
    }
    else if ([self isThrowingAway:tileCell]) {
        [self tossTile:tileCell];
        return YES;
    }
    else {
        [self takeTileFromBoard:tileCell];
    }
    return NO;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    if ([self tileIsSelected]) {
        [self takeTileFromBoard:[self selectedTile]];
    }
}

- (IBAction)touchUpSubmit:(id)sender {
    NSArray *boardCheckerResults = [self.boardChecker checkBoardState:self.board];
    NSArray *invalidWordsOnBoard = boardCheckerResults[0];
    NSArray *notConnectedWordsOnBoard = boardCheckerResults[1];
    if ([invalidWordsOnBoard count] > 0 || [notConnectedWordsOnBoard count] > 0) {
        
        NSString *alertMessage = @"";
        
        if ([invalidWordsOnBoard count] > 0)  {
            alertMessage = [alertMessage stringByAppendingString: @"Found the following invalid words: "];
            alertMessage = [alertMessage stringByAppendingString:[invalidWordsOnBoard componentsJoinedByString:@", "]];
        }
        
        if ([notConnectedWordsOnBoard count] > 0) {
            alertMessage = [alertMessage stringByAppendingString:@"\n Found the following not connected words: "];
            alertMessage = [alertMessage stringByAppendingString:[notConnectedWordsOnBoard componentsJoinedByString:@", "]];
        }
        
        if (objc_getClass("UIAlertController") != nil){
            
            //create an alert
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Invalid Board"
                                          message:alertMessage
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            [self presentViewController:alert animated:YES completion:nil];
            
            //create ok action for alert
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     if (isGameOver) {
                                         [self gameOver];
                                     }
                                     
                                 }];
            
            [alert addAction:ok]; // add action to uialertcontroller
            
        }
        else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Board" message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        }
        
    } else {
        
        //RACE AVOIDANCE
        NSMutableDictionary *lockProperties = [[NSMutableDictionary alloc] init];
        for (int i = 0; i<[self.board count]; i++) {
            BoardCellDTO *cellDTO = self.board[i];
            TileViewCell *tvc = cellDTO.tvc;
            if(tvc.isUnsent){
                [lockProperties setObject:@"-" forKey:[NSString stringWithFormat:@"%d",i]];
            }
        }
        
        int num = STARTING_NUMBER_OF_TILES - currentPlayer.numberOfTiles;
        for (int i = 0; i < num; i++) {
            [self createTileInRack];
        }
        [self updateSelfScore];
        
        //TODO: Need to move this to a seperate callable method
        
        //Play a sound
        SystemSoundID audioEffect;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef) successNoisePathURL, &audioEffect);
        AudioServicesPlaySystemSound(audioEffect);
        
        // Using GCD, we can use a block to dispose of the audio effect without using a NSTimer or something else to figure out when it'll be finished playing.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            AudioServicesDisposeSystemSoundID(audioEffect);
        });
        [self finalizePendingEnemyTilesForPlayer:[GameConstants getUserName]];
        
    }
}


- (IBAction)recallTiles:(id)sender {
    for (TileViewCell *cell in self.allTiles) {
        if ([cell.pid isEqualToString:[GameConstants getUserName]]) {
            [self takeTileFromBoard:cell];
        }
    }
}

- (IBAction)shuffleTiles:(id)sender {
    NSMutableArray *tileViewCellsOnRack = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.allTiles count]; i++) {
        if (((TileViewCell *)self.allTiles[i]).isOnRack) {
            [self removeTileFromRack:((TileViewCell *)self.allTiles[i])];
            [tileViewCellsOnRack addObject:self.allTiles[i]];
        }
    }
    [self shuffleArray:self.rackTileFrames];
    for (int i = 0; i < [tileViewCellsOnRack count]; i++) {
        TileViewCell *cell = (TileViewCell *)tileViewCellsOnRack[i];
        CGRect rect = [self.rackTileFrames[i] CGRectValue];
        [UIView animateWithDuration:0.1 animations:^{
            cell.frame = rect;
        }];
    }
}


-(void)shuffleArray:(NSMutableArray *) inputArray{
    NSUInteger count = [inputArray count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [inputArray exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}

-(void)submitWasSuccessful {
    
}

-(void)submitWasUnSuccessful {
    //What behavior do we want?
}

-(void)releaseLocks {
    
}

#pragma mark – UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    TILE_WIDTH = self.boardCollectionView.bounds.size.width/10;
    TILE_HEIGHT = self.boardCollectionView.bounds.size.width/10;
    
    return CGSizeMake(TILE_WIDTH, TILE_HEIGHT);
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - Creation and Destruction of tiles

-(void) createTileInRack {
    TileViewCell *newTile = [[TileViewCell alloc] initWithFrame:[[_tileSpaces objectAtIndex:0] CGRectValue] playerID:[GameConstants getUserName]];
    [newTile setColorOfTile:currentPlayer.color];
    [_tileSpaces removeObjectAtIndex:0];
    
    [self.view addSubview:newTile];
    [self.allTiles addObject:newTile];
    currentPlayer.numberOfTiles++;
}

-(void) destroyTile:(TileViewCell *)tile {
    [self removeTileFromCurrentSpot:tile];
    [tile removeFromSuperview];
}

#pragma mark - placing tiles

-(void) placeTileOnBoard:(TileViewCell *)tile atIndexPath:(NSIndexPath *) indexPath {
    BoardCellDTO *dto = self.board[indexPath.item];
    dto.tvc = tile;
    dto.tileWasHere = YES;
    dto.tvc.isUnsent = YES;
}

-(void)placeStartingWord{

    NSString *starting_word = [[GameHost sharedGameHost] getStartingWord];
    
    if([self.startingWordTiles count] > 0){
        for(int i = 0; i < [self.startingWordTiles count]; i++){
            NSString *letter = [NSString stringWithFormat:@"%c" , [starting_word characterAtIndex:i]];
            TileViewCell *tvc = [self.startingWordTiles objectAtIndex:i];
            tvc.letterLabel.text = letter;
            [self.view addSubview:tvc];
            if (![self.allTiles containsObject:tvc]) {
                [self.allTiles addObject:tvc];
            }
            [self placeTileOnBoard:tvc  atIndexPath:[NSIndexPath indexPathForItem:(43 + i) inSection:0]];
        }
        return;
    }
    
    for(int i = 0; i < starting_word.length; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(43 + i) inSection:0];
        UICollectionViewCell *cell = [self.boardCollectionView cellForItemAtIndexPath:indexPath];
        CGRect frame = CGRectMake(cell.frame.origin.x + self.boardCollectionView.frame.origin.x, cell.frame.origin.y + self.boardCollectionView.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
        NSString *letter = [NSString stringWithFormat:@"%c" , [starting_word characterAtIndex:i]];
        TileViewCell *tvc = [[TileViewCell alloc] initWithFrame:frame letter:letter playerUserName:@"stone"];
        [self.view addSubview:tvc];
        [self.allTiles addObject:tvc];
        [self placeTileOnBoard:tvc atIndexPath:indexPath];
    }
    
    [self.boardCollectionView reloadData];
    
}


-(void) takeTileFromBoard:(UIView *)tile {
    TileViewCell *theTile = ((TileViewCell *)tile);
    if (currentPlayer.numberOfTiles < STARTING_NUMBER_OF_TILES && !theTile.isFinalized && ![theTile.pid isEqualToString:@"stone"]) {
        [UIView animateWithDuration:0.1 animations:^{
            tile.frame =[[_tileSpaces objectAtIndex:0] CGRectValue];
        }];
        
        //send update packet
        NSString* message = [NSString stringWithFormat:@"letterReturned:%ld", (long)theTile.indexPath.item];
        [NetworkUtils sendLetterReturned:message];
        
        [_tileSpaces removeObjectAtIndex:0];
        [self clearOutlingColor:theTile];
        [self removeTileFromCurrentSpot:theTile];
        currentPlayer.numberOfTiles++;
        theTile.isOnRack = YES;
        [theTile makeUnselected];
        [theTile setColorOfTile:currentPlayer.color];
        theTile.startPoint = tile.frame.origin;
        
        [self clearSelectedTile];
    }
}

-(BOOL) playTile: (TileViewCell *)tile atIndexPath:(NSIndexPath *)indexPath onCell:(BoardViewCell*)bvc{
    BoardCellDTO *dto = ((BoardCellDTO *)self.board[indexPath.item]);
    NSString *currentSelectedLetter = tile.letterLabel.text;
    
    if (dto.tvc == nil) {
        
        //send update packet
        NSString* message = [NSString stringWithFormat:@"%ld:%@", (long)indexPath.item, currentSelectedLetter];
        [NetworkUtils sendLetterPlayed:message];
        
        //update the board
        [self removeTileFromCurrentSpot:tile];
        [self placeTileOnBoard:tile atIndexPath:indexPath];
        [self.boardCollectionView reloadData];
        
        if(dto.player != currentPlayer && dto.player != nil){
            [dto.tvc.layer setBorderColor:[[GameHost sharedGameHost] getColorForPlayer:dto.player.userName].CGColor];
            [dto.tvc.layer setBorderWidth:2.0f];
        } else {
            [self clearOutlingColor:dto.tvc];
        }
        
        CGRect newFrame = CGRectMake(bvc.frame.origin.x + self.boardCollectionView.frame.origin.x, bvc.frame.origin.y+ self.boardCollectionView.frame.origin.y, tile.frame.size.width, tile.frame.size.height);
        tile.frame = newFrame;
        tile.startPoint = newFrame.origin;
        tile.indexPath = indexPath;
        tile.isOnRack = NO;
        
        return NO;
    } else {
//        NSLog(@"TVC WAS NOT NIL");
    }
    return NO;
}

#pragma mark - coloring

-(void)clearOutlingColor:(TileViewCell *)tvc{
    [tvc.layer setBorderColor:[UIColor clearColor].CGColor];
    [tvc.layer setBorderWidth:2.0f];
}

#pragma mark - remove tiles

-(void) removeTileFromBoard:(TileViewCell *)tile {
    BoardCellDTO *dto = self.board[tile.indexPath.item];
    dto.tvc = nil;
    [self clearOutlingColor:dto.tvc];
    NSString* message = [NSString stringWithFormat:@"pendingRemove:%ld", (long)tile.indexPath.item];
    [NetworkUtils sendLetterRemoved:message];
}

-(void) removeTileFromRack:(TileViewCell *)tile {
    CGRect rec = CGRectMake(tile.startPoint.x, tile.startPoint.y, tile.frame.size.width, tile.frame.size.height);
    currentPlayer.numberOfTiles--;
    [self.tileSpaces addObject:[NSValue valueWithCGRect:rec]];
}

-(void) removeTileFromCurrentSpot:(TileViewCell *)tile {
    if (tile.isOnRack) {
        [self removeTileFromRack:tile];
    }
    else {
        [self removeTileFromBoard:tile];
        
    }
}

#pragma mark - Toss Tiles

-(void)tossWasTouched:(UITouch *)touch {
    if(_touchToPlay){
        if([self tileIsSelected]){
            TileViewCell *tile = _selectedTile;
            [self clearSelectedTile];
            [self tossTile:tile];
        }
    }
}

-(BOOL) isThrowingAway:(TileViewCell *)tile {
    float curDist = [self view:tile DistanceToView:_tossView] - 50;
    float a =  tile.frame.size.height + _tossView.frame.size.height;
    float b = tile.frame.size.height/2 + _tossView.frame.size.height/2;
    
    if (tile.isOnRack && curDist < tile.frame.size.height + _tossView.frame.size.height) {
        return YES;
    }
    return NO;
}

-(void) tossTile:(TileViewCell *)tile {
    if (!tile.isFinalized) {
        [self destroyTile:tile];
        [self createTileInRack];
        NSUInteger newScore = [[self.playerScores valueForKey:currentPlayer.userName] integerValue] - 100;
        [self.playerScores setValue:[NSNumber numberWithLong:newScore] forKey:currentPlayer.userName];
        currentPlayer.score = (int)newScore;
        [NetworkUtils sendPlayerScore:[NSString stringWithFormat:@"%ld", (unsigned long)newScore]];
    }
}

#pragma mark - scoring
-(void) updateSelfScore {
    NSUInteger pointsEarned = [self.boardChecker calculateScoreForBoard:self.board andPlayer:currentPlayer.userName];
    NSUInteger oldScore = [[self.playerScores valueForKey:currentPlayer.userName] integerValue];
    NSUInteger newScore = pointsEarned + oldScore;
    currentPlayer.score = (int)newScore;
    //NSUInteger newScore = pointsEarned;
    [self.playerScores setValue:[NSNumber numberWithLong:newScore] forKey:currentPlayer.userName];
    [NetworkUtils sendPlayerScore:[NSString stringWithFormat:@"%ld", (unsigned long)newScore]];
}

-(void)updateScore:(NSUInteger)score forPlayer:(NSString *)userName {
    [self.playerScores setValue:[NSNumber numberWithLong:score] forKey:userName];
    [self getPlayerByUsername:userName].score = (int)score;
}

-(void) resetScores {
    for (NSString *playerName in self.playerScores.allKeys) {
        [self.playerScores setValue:0 forKey:playerName];
    }
}

-(Player *)getPlayerByUsername:(NSString * )userName {
    for(Player *player in [self players]){
        if([player.userName isEqualToString:userName]){
            return player;
        }
    }
    return nil;
}

#pragma mark - Networking Calls

-(void)addPlayer:(NSString *)playerUserName {
    if([self getPlayerByUsername:playerUserName]){
        return;
    }
    Player *player = [[Player alloc] init];
    player.userName = playerUserName;
    player.color = [[GameHost sharedGameHost] getColorForPlayer:player.userName];
    player.playerNumber = playerNumber;
    playerNumber = playerNumber + 1;
    [self.players addObject:player];
    [self.playerScores setValue:[NSNumber numberWithInt:0] forKey:playerUserName];
}

-(void)updatePlayerList:(NSArray *)currentPlayers {
    self.players = [[NSMutableArray alloc] init];
    for (NSString *playerName in currentPlayers) {
        Player *newPlayer = [[Player alloc] init];
        newPlayer.userName = playerName;
        [self.players addObject:newPlayer];
        [self.playerScores setValue:[NSNumber numberWithInt:0] forKey:playerName];
    }
}

-(void)setLetterBeingMovedAtIndexPath:(NSIndexPath *)indexPath  {
    BoardCellDTO *dto = self.board[indexPath.item];
    if (dto.isPending == 0) {
        [dto.tvc makeBeingMovedByOtherPlayer];
    }
    else {
        [dto.tvc unMakeBeingMovedByOtherPlayer];
        [self removeEnemyPendingLetterAtIndexPath:indexPath];
    }
}

-(void)placeEnemyPendingLetter:(NSString *)letter atIndexPath:(NSIndexPath *)indexPath forEnemy:(NSString *)enemyID {
    BoardCellDTO *dto = self.board[indexPath.item];
    if(dto.tvc != nil && [dto.tvc.pid isEqualToString:currentPlayer.userName]){
        [dto.tvc.layer setBorderColor:[[GameHost sharedGameHost] getColorForPlayer:enemyID].CGColor];
        [dto.tvc.layer setBorderWidth:2.0f];
    }
    dto.player = [self getPlayerByUsername:enemyID];
    if (dto.tvc != nil && dto.tvc.isBeingMovedByOtherPlayer && [dto.tvc.letterLabel.text isEqualToString: letter]) {
        // For when someone was going to move a tile but moved it back
        [dto.tvc unMakeBeingMovedByOtherPlayer];
        dto.tvc.isUnsent = NO;
    }
    else {
        dto.isPending++;
    }
    [self.boardCollectionView reloadData];
}

-(void)placeEnemyFinalLetter:(NSString *)letter atIndexPath:(NSIndexPath *)indexPath forEnemy:(NSString *)enemyID{
    BoardCellDTO *dto =self.board[indexPath.item];
    UICollectionViewCell *cell = dto.cell;
    if (cell == nil) {
        NSLog(@"Something bad happened! %ld", (long)indexPath.item);
    }
    CGRect frame = CGRectMake(cell.frame.origin.x + self.boardCollectionView.frame.origin.x, cell.frame.origin.y + self.boardCollectionView.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
    TileViewCell *tvc = [[TileViewCell alloc] initWithFrame:frame letter:letter playerUserName:enemyID];
    tvc.indexPath = indexPath;
    [tvc makeFinalized:100];
    
    //case where we have unsent tiles that are being written over
    if (dto.tvc != nil && dto.tvc.isUnsent) {
        [self takeTileFromBoard:dto.tvc];
    }
    //case where there is a tile still there so we want to remove it
    if(dto.tvc != nil){
        TileViewCell *tile = dto.tvc;
        dto.tvc = nil;
        [tile removeFromSuperview];
    }
    [self placeTileOnBoard:tvc atIndexPath:indexPath];
    dto.isPending = 0;
    dto.tvc.isUnsent = NO;
    [self.view addSubview:tvc];
    [self.allTiles addObject:tvc];
}

-(void)finalizePendingEnemyTilesForPlayer:(NSString *)player {
    NSMutableString *finalLetterMessage = [[NSMutableString alloc] initWithString:@"f" ];
    for (int i = 0; i < [self.board count]; i++) {
        BoardCellDTO *cellDTO = self.board[i];
        
        if (!cellDTO.tvc.isStartingTile && cellDTO.tvc.isUnsent) {
            cellDTO.isPending = 0;
            cellDTO.tvc.isUnsent = NO;
//            NSLog(@"i %ld, j %ld\n", (long)i, (long)cellDTO.tvc.indexPath.item);
            [finalLetterMessage appendFormat:@":a:%ld:%@",(long)cellDTO.tvc.indexPath.item, cellDTO.tvc.letterLabel.text];
            [cellDTO.tvc makeFinalized:100];
        }
        else if (cellDTO.tvc == nil && cellDTO.tileWasHere) {
            cellDTO.tileWasHere = NO;
//            NSLog(@"i %ld, j %ld\n", (long)i, (long)cellDTO.tvc.indexPath.item);
            //send removed tile update
            [finalLetterMessage appendFormat:@":r:%ld:%@",(long)i, @"-"];
            
        }
    }
    [NetworkUtils sendFinalLetterPlayed:finalLetterMessage];
}

-(void)removeEnemyPendingLetterAtIndexPath:(NSIndexPath *)indexPath {
    BoardCellDTO *dto = self.board[indexPath.item];
    dto.isPending--;
    dto.player = nil;
    
    if(dto.tvc != nil && [dto.tvc.pid isEqualToString:currentPlayer.userName]){
        [self clearOutlingColor:dto.tvc];
    }
    
    [self.boardCollectionView reloadData];
}

-(void)removeEnemyFinalLetterAtIndexPath:(NSIndexPath *)indexPath {
    BoardCellDTO *dto =self.board[indexPath.item];
    [dto.tvc removeFromSuperview];
    
    dto.tvc = nil;
    dto.isPending = 0;
    [self.boardCollectionView reloadData];
}

-(void)leaveGame{
    [[WarpClient getInstance] disconnect];
}

#pragma mark - ViewHelperMethods

-(BoardViewCell *) findClosestCellToView:(UIView *)view {
    float minDist = -1;
    BoardViewCell *closestCell = nil;
//    NSLog(@"visible %@", _boardCollectionView.visibleCells);
    for (BoardViewCell *cell in _boardCollectionView.visibleCells) {
        float curDist = [self view:view DistanceToView:cell];
        if (curDist < view.frame.size.height / 2 + cell.frame.size.height / 2) {
            if (curDist < minDist || minDist == -1) {
                minDist = curDist;
                closestCell = cell;
            }
        }
    }
    return closestCell;
}

-(float) view:(UIView *)view DistanceToView:(UIView *)otherView {
    return sqrt(pow(view.center.x - otherView.center.x - _boardCollectionView.frame.origin.x, 2) +
                pow(view.center.y - otherView.center.y - _boardCollectionView.frame.origin.y, 2));
}

-(void) unhighlightAllCells {
    for (UICollectionViewCell *cell in _boardCollectionView.visibleCells) {
        cell.layer.borderWidth = 1.0f;
        cell.layer.borderColor = [UIColor blackColor].CGColor;
    }
}

-(void) highlightCell:(BoardViewCell *)bvc {
    bvc.layer.borderWidth = 2.0f;
    bvc.layer.borderColor = [UIColor whiteColor].CGColor;
}
@end
