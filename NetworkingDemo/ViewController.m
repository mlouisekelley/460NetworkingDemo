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
#import "BoardChecker.h"
#import "BoardCellDTO.h"
#import "Player.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioPlayer.h>

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *tileCollectionView;
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
int redScore = 0;
int blueScore = 0;
int purpleScore = 0;
NSMutableArray *colorArray;

- (void)viewDidLoad {
    
    isGameOver = NO;
    
    colorArray = [[NSMutableArray alloc] initWithObjects:[UIColor redColor],[UIColor blueColor],[UIColor purpleColor], nil];
    
    _touchToPlay = true;
    
    [super viewDidLoad];
    [self.boardCollectionView setTag:1];
    [self.tileCollectionView setTag:2];
    
    [self.boardCollectionView reloadData];
    self.boardCollectionView.dataSource = self;
    self.boardCollectionView.delegate = self;
    self.boardCollectionView.minimumZoomScale = .01;
    self.boardCollectionView.zoomScale = 10;
    
    
    [self.tileCollectionView reloadData];
    self.tileCollectionView.dataSource = self;
    self.tileCollectionView.delegate = self;
    
    vc = self;
    currentPlayer = [[Player alloc] init];
    currentPlayer.userName = [GameConstants getUserName];
    currentPlayer.color = [UIColor orangeColor];
    _allTiles = [[NSMutableArray alloc] init];
    UIImage *img = [UIImage imageNamed:@"trash-64.png"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
    
    [self.tossView addSubview:imageView ];
    [self.tossView sendSubviewToBack:imageView ];
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateCounter)];
    _scoreTimer = [NSTimer scheduledTimerWithTimeInterval:0.04f target:self selector:@selector(updateScoreDisplay:) userInfo:nil repeats:YES];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.bkgView addGestureRecognizer:tapGesture];
}

-(void) setUpGame {
    minutes = 2;
    seconds = 0;
    milliseconds = 0;
    
    redScore = 0;
    blueScore = 0;
    purpleScore = 0;
    
    currentPlayer.numberOfTiles = 0;
    
    for (TileViewCell *cell in self.allTiles) {
        [cell removeFromSuperview];
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
        CGRect rec = CGRectMake(i * (TILE_WIDTH + 30) + self.boardCollectionView.frame.origin.x + 15, self.boardCollectionView.frame.origin.y + (self.boardCollectionView.bounds.size.height - TILE_HEIGHT - 30), TILE_WIDTH, TILE_HEIGHT);
        [self.tileSpaces addObject:[NSValue valueWithCGRect:rec]];
        [self createTileInRack];
    }
    [self placeStartingWord];
    [self refreshScoresText];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];

}

-(void)resetBoard {
    _board = [[NSMutableArray alloc] init];
    for (int i = 0; i < 10; i++) {
        for (int j = 0; j < 10; j++) {
            BoardCellDTO *cell = [[BoardCellDTO alloc] init];
            cell.text = @"-";
            cell.isPending = NO;
            [_board addObject:cell];
            cell.tvc = nil;
        }
    }
}

#pragma mark Lazy Instantiations
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
                cell.text = @"-";
                cell.isPending = NO;
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
- (void)updateCounter {
    NSTimeInterval timeSince = [_displayLink duration];
    NSLog (@"%f", timeSince);
    int mil = 1000 * (timeSince - floor(timeSince));
    int sec = floor(timeSince);
    seconds -= sec;
    if (milliseconds > 0) {
        milliseconds -= mil;
    }
    else if (seconds > 0) {
        milliseconds = 1000;
        seconds--;
    }
    else if (minutes > 0) {
        seconds = 59;
        minutes--;
    }
    else if (!isGameOver) {
        [self gameOver];
    }
    if (seconds <= 5 && minutes == 0) {
        self.countDownLabel.text = [NSString stringWithFormat:@"%d", seconds];
        self.countDownLabel.alpha = 0.5 * (milliseconds) / 1000.0 + .2;
    }
    else {
        self.countDownLabel.text = @"";
    }
    self.circleTimerView.percent = (minutes * 60.0 * 1000 + seconds * 1000 + milliseconds) / (120 * 1000.0);
    self.circleTimerView.seconds = seconds + minutes * 60;
    self.circleTimerView.milliseconds = milliseconds;
    [self.circleTimerView setNeedsDisplay];
    [self.view bringSubviewToFront:self.circleTimerView];
    self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
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
    self.currentPlayerScoreLabel.text = [NSString stringWithFormat:@"%08d", displayScore];
    [self updateEnemyScores];
}

-(void)updateEnemyScores{
    for(Player *player in [self players]){
        
        //red player
        if([player.color isEqual:[UIColor redColor]]){
            if (redScore < player.score) {
                int incAmnt = (player.score - redScore) / 9 + 1;
                if (redScore + incAmnt > player.score) {
                    redScore = player.score;
                }
                else {
                    redScore += incAmnt;
                }
            }
            else {
                redScore = player.score;
            }
            self.redPlayerScore.text = [NSString stringWithFormat:@"%08d", redScore];
        }
        
        //blue player
        if([player.color isEqual:[UIColor blueColor]]){
            if (blueScore < player.score) {
                int incAmnt = (player.score - blueScore) / 9 + 1;
                if (blueScore + incAmnt > player.score) {
                    blueScore = player.score;
                }
                else {
                    blueScore += incAmnt;
                }
            }
            else {
                blueScore = player.score;
            }
            self.bluePlayerScore.text = [NSString stringWithFormat:@"%08d", blueScore];
        }
        
        //purple player
        if([player.color isEqual:[UIColor purpleColor]]){
            if (purpleScore < player.score) {
                int incAmnt = (player.score - purpleScore) / 9 + 1;
                if (purpleScore + incAmnt > player.score) {
                    purpleScore = player.score;
                }
                else {
                    purpleScore += incAmnt;
                }
            }
            else {
                purpleScore = player.score;
            }
            self.purplePlayerScore.text = [NSString stringWithFormat:@"%08d", purpleScore];
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
        
        //create ok action for alert
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"Again!"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                                 [self restart];
                             }];
        
        [alert addAction:ok]; // add action to uialertcontroller
        
    }
    else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Board" message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
}

-(BOOL) didCurrentPlayerWin {
    Player *maxPlayer = nil;
    for (Player *player in self.players) {
       if (maxPlayer == nil || maxPlayer.score < player.score) {
           maxPlayer = player;
       }
    }
    if([maxPlayer.userName isEqualToString:[GameConstants getUserName]]){
        return YES;
    }
    return NO;
}

-(void)restart {
    //    [vc performSegueWithIdentifier:@"ReturnToLobby" sender:vc];
    isGameOver = NO;
    [self setUpGame];
    for (int i = 0; i < STARTING_NUMBER_OF_TILES; i++) {
        CGRect rec = CGRectMake(i * (TILE_WIDTH + 30) + self.boardCollectionView.frame.origin.x + 15, self.boardCollectionView.frame.origin.y + (self.boardCollectionView.bounds.size.height - TILE_HEIGHT - 30), TILE_WIDTH, TILE_HEIGHT);
        [self.tileSpaces addObject:[NSValue valueWithCGRect:rec]];
        [self createTileInRack];
    }
    
    //    [self placeStartingWord];
    [self refreshScoresText];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView.tag == 1) {
        return 100;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.tag == 1) {
        //use self.board to determine how the board looks
        BoardViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"board cell" forIndexPath:indexPath];
        NSString *text = ((BoardCellDTO *)self.board[indexPath.item]).text;
        
        text = @"";
        BoardCellDTO *dto = (BoardCellDTO *)self.board[indexPath.item];
        dto.cell = cell;
        if (dto.isPending) {
            cell.backgroundColor = dto.player.color;
        }
        else {
            cell.backgroundColor = [UIColor lightGrayColor];
        }
        cell.layer.borderWidth=1.0f;
        
        cell.layer.borderColor=[UIColor whiteColor].CGColor;
        cell.textLabel.text = text;
        cell.textLabel.textColor = [UIColor blackColor];
        return cell;
    }
    
    return nil;
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
    NSArray *invalidWordsOnBoard = [self.boardChecker checkBoardState:self.board];
    if ([invalidWordsOnBoard count] > 0) {
        
        NSString *alertMessage = @"Found the following invalid words: ";
        alertMessage = [alertMessage stringByAppendingString:[invalidWordsOnBoard componentsJoinedByString:@", "]];
        
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
                                     
                                 }];
            
            [alert addAction:ok]; // add action to uialertcontroller
            
//            int num = STARTING_NUMBER_OF_TILES - currentPlayer.numberOfTiles;
//            for (int i = 0; i < num; i++) {
//                [self createTileInRack];
//            }
            //[self updateSelfScore];
            
        }
        else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Board" message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        }
        
    } else {
        
        int num = STARTING_NUMBER_OF_TILES - currentPlayer.numberOfTiles;
        for (int i = 0; i < num; i++) {
            [self createTileInRack];
        }
        [self updateSelfScore];
        NSString *path  = [[NSBundle mainBundle] pathForResource:@"success" ofType:@"m4a"];
        NSURL *pathURL = [NSURL fileURLWithPath : path];
        
        //Play a sound
        SystemSoundID audioEffect;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
        AudioServicesPlaySystemSound(audioEffect);
        
        // Using GCD, we can use a block to dispose of the audio effect without using a NSTimer or something else to figure out when it'll be finished playing.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            AudioServicesDisposeSystemSoundID(audioEffect);
        });
        [self finalizePendingEnemyTilesForPlayer:[GameConstants getUserName]];
        
    }
}

#pragma mark – UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    TILE_WIDTH = self.boardCollectionView.bounds.size.width/10;
    TILE_HEIGHT = self.boardCollectionView.bounds.size.width/10;
    
    return CGSizeMake(TILE_WIDTH, TILE_HEIGHT);
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (collectionView.tag == 1) {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    else return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark - Creation and Destruction of tiles

-(void) createTileInRack {
    TileViewCell *newTile = [[TileViewCell alloc] initWithFrame:[[_tileSpaces objectAtIndex:0] CGRectValue] playerID:[GameConstants getUserName]];
    
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
    dto.text = tile.letterLabel.text;
    dto.tvc = tile;
    dto.tileWasHere = YES;
    dto.tvc.isUnsent = YES;
}

-(void)placeStartingWord{
    
    NSArray *starting_words = @[@"START"];
    NSString *starting_word = [starting_words objectAtIndex: arc4random() % [starting_words count]];
    
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
    if (currentPlayer.numberOfTiles < STARTING_NUMBER_OF_TILES) {
        [UIView animateWithDuration:0.1 animations:^{
            tile.frame =[[_tileSpaces objectAtIndex:0] CGRectValue];
        }];
        
        
        [_tileSpaces removeObjectAtIndex:0];
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

#pragma mark - remove tiles

-(void) removeTileFromBoard:(TileViewCell *)tile {
    BoardCellDTO *dto = self.board[tile.indexPath.item];
    dto.text = @"-";
    dto.tvc = nil;
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
    float curDist = [self view:tile DistanceToView:_tossView];
    if (tile.isOnRack && curDist < tile.frame.size.height/2 + _tossView.frame.size.height/2) {
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
        [self refreshScoresText];
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
    [self refreshScoresText];
    [NetworkUtils sendPlayerScore:[NSString stringWithFormat:@"%ld", newScore]];
}

-(void)updateScore:(NSUInteger)score forPlayer:(NSString *)userName {
    [self.playerScores setValue:[NSNumber numberWithLong:score] forKey:userName];
    [self getPlayerByUsername:userName].score = (int)score;
    [self refreshScoresText];
}

-(void) resetScores {
    for (NSString *playerName in self.playerScores.allKeys) {
        [self.playerScores setValue:0 forKey:playerName];
    }
}


-(void) refreshScoresText {
    NSString *scoresString = @"SCORES:\n";
    for (NSString *playerName in self.playerScores.allKeys) {
        NSNumber *num = [self.playerScores valueForKey:playerName];
        if([playerName isEqualToString:[GameConstants getUserName]]){
            scoresString = [scoresString stringByAppendingFormat:@"Me: %d\n", [num intValue]];
        } else {
            scoresString = [scoresString stringByAppendingFormat:@"%@: %d\n", playerName, [num intValue]];
        }
    }
    self.scores.font = [UIFont fontWithName:@"orange juice" size:32];
    
    self.scores.text = scoresString;
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
    player.color = [colorArray objectAtIndex:0];
    [colorArray removeObjectAtIndex:0];
    [self.players addObject:player];
    [self.playerScores setValue:[NSNumber numberWithInt:0] forKey:playerUserName];
    [self refreshScoresText];
}

-(void)updatePlayerList:(NSArray *)currentPlayers {
    self.players = [[NSMutableArray alloc] init];
    for (NSString *playerName in currentPlayers) {
        Player *newPlayer = [[Player alloc] init];
        newPlayer.userName = playerName;
        [self.players addObject:newPlayer];
        [self.playerScores setValue:[NSNumber numberWithInt:0] forKey:playerName];
    }
    [self refreshScoresText];
}

-(void)setLetterBeingMovedAtIndexPath:(NSIndexPath *)indexPath  {
    BoardCellDTO *dto = self.board[indexPath.item];
    if (!dto.isPending) {
        [dto.tvc makeBeingMovedByOtherPlayer];
    }
    else {
        [dto.tvc unMakeBeingMovedByOtherPlayer];
        [self removeEnemyPendingLetterAtIndexPath:indexPath];
    }
}

-(void)placeEnemyPendingLetter:(NSString *)letter atIndexPath:(NSIndexPath *)indexPath forEnemy:(NSString *)enemyID {
    BoardCellDTO *dto = self.board[indexPath.item];
    dto.player = [self getPlayerByUsername:enemyID];
    if (dto.tvc != nil && dto.tvc.isBeingMovedByOtherPlayer && [dto.tvc.letterLabel.text isEqualToString: letter]) {
        // For when someone was going to move a tile but moved it back
        [dto.tvc unMakeBeingMovedByOtherPlayer];
        dto.tvc.isUnsent = NO;
    }
    else {
        dto.isPending = YES;
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
    [tvc makeFinalized];
    
    
    if (dto.tvc != nil && dto.tvc.isUnsent) {
        [self takeTileFromBoard:dto.tvc];
    }
    [self placeTileOnBoard:tvc atIndexPath:indexPath];
    dto.isPending = NO;
    dto.tvc.isUnsent = NO;
    [self.view addSubview:tvc];
    [self.allTiles addObject:tvc];
}

-(void)finalizePendingEnemyTilesForPlayer:(NSString *)player {
    NSMutableString *finalLetterMessage = [[NSMutableString alloc] initWithString:@"f" ];
    for (int i = 0; i < [self.board count]; i++) {
        BoardCellDTO *cellDTO = self.board[i];
        
        if (!cellDTO.tvc.isStartingTile && cellDTO.tvc.isUnsent) {
            cellDTO.isPending = NO;
            cellDTO.tvc.isUnsent = NO;
//            NSLog(@"i %ld, j %ld\n", (long)i, (long)cellDTO.tvc.indexPath.item);
            [finalLetterMessage appendFormat:@":a:%ld:%@",(long)cellDTO.tvc.indexPath.item, cellDTO.tvc.letterLabel.text];
            [cellDTO.tvc makeFinalized];
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
    BoardCellDTO *dto =self.board[indexPath.item];
    dto.isPending = NO;
    
    [self.boardCollectionView reloadData];
}

-(void)removeEnemyFinalLetterAtIndexPath:(NSIndexPath *)indexPath {
    BoardCellDTO *dto =self.board[indexPath.item];
    [dto.tvc removeFromSuperview];
    
    dto.tvc = nil;
    dto.text = @"-";
    dto.isPending = NO;
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
    return sqrt(pow(view.center.x - otherView.center.x - _boardCollectionView.frame.origin.x, 2) + pow(view.center.y - otherView.center.y - _boardCollectionView.frame.origin.y, 2));
}

-(void) unhighlightAllCells {
    for (UICollectionViewCell *cell in _boardCollectionView.visibleCells) {
        cell.layer.borderWidth = 1.0f;
        cell.layer.borderColor = [UIColor whiteColor].CGColor;
    }
}

-(void) highlightCell:(BoardViewCell *)bvc {
    bvc.layer.borderWidth = 2.0f;
    bvc.layer.borderColor = [UIColor blackColor].CGColor;
}
@end
