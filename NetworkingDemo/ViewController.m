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

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *tileCollectionView;
@property (strong, nonatomic) NSMutableArray *board;
@property (strong, nonatomic) NSMutableArray *tileSpaces;
@property (nonatomic) NSInteger selectedIndex;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSMutableArray *players;
@property (strong, nonatomic) NSMutableDictionary *playerScores;
@property (strong, nonatomic) TileViewCell *selectedTile;
@property (strong, nonatomic) BoardChecker *boardChecker;
@end

@implementation ViewController

static ViewController *vc;
Player *currentPlayer;
int minutes;
int seconds;
BOOL isGameOver = NO;
int TILE_WIDTH;
int TILE_HEIGHT;

- (void)viewDidLoad {
    
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
    minutes = 2;
    seconds = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCounter:) userInfo:nil repeats:YES];

    
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGRect bounds = self.boardCollectionView.bounds;
    CGRect frame = self.boardCollectionView.frame;

    for (int i = 0; i < STARTING_NUMBER_OF_TILES; i++) {
        CGRect rec = CGRectMake(i * (TILE_WIDTH + 20) + self.boardCollectionView.frame.origin.x, self.boardCollectionView.frame.origin.y + self.boardCollectionView.bounds.size.height, TILE_WIDTH, TILE_HEIGHT);
        [self.tileSpaces addObject:[NSValue valueWithCGRect:rec]];
        [self addTile];
    }
    
    //[self placeStartingWord];
    [self refreshScoresText];
    
}

- (NSMutableDictionary *)playerScores {
    if (!_playerScores) {
        _playerScores = [[NSMutableDictionary alloc] init];
    }
    return _playerScores;
}

- (BoardChecker *) boardChecker {
    if (!_boardChecker) {
        _boardChecker = [[BoardChecker alloc] init];
    }
    return _boardChecker;
}

// Methods For Touch and Tap Type of Playing Tiles

-(BOOL)tileIsSelected {
    if(!_selectedTile){
        return false;
    }
    return true;
}

-(void)setSelectedTile:(TileViewCell *)tile
{
    _selectedTile = tile;
}

-(void)clearSelectedTile
{
    if(_selectedTile){
        [_selectedTile makeFinalized];
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

//end

-(void)placeStartingWord{
    
    for(int i = 0; i < 5; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewCell *cell = [self.boardCollectionView cellForItemAtIndexPath:indexPath];
        CGRect frame = CGRectMake(cell.frame.origin.x + self.boardCollectionView.frame.origin.x, cell.frame.origin.y + self.boardCollectionView.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
        TileViewCell *tvc = [[TileViewCell alloc] initWithFrame:frame letter:@"S" playerUserName:@"stone"];
        [self.view addSubview:tvc];
        
        BoardCellDTO *dto = (BoardCellDTO *)self.board[indexPath.item];
        dto.text = @"S";
        dto.playerUserName = [GameConstants getUserName];
        dto.tvc = tvc;
    }
    
    [self.boardCollectionView reloadData];
    
}

- (void)updateCounter:(NSTimer *)theTimer {
    if (seconds > 0) {
        seconds--;
    }
    else if (minutes > 0) {
        seconds = 59;
        minutes--;
    }
    else if (!isGameOver) {
        [self gameOver];
    }
    self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

-(void) gameOver {
    isGameOver = YES;
    NSString *alertMessage = @"";
    
    if ([self currentPlayerWon]) {
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
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        
        [alert addAction:ok]; // add action to uialertcontroller
        
    }
    else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Board" message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
    
    [self leaveGame];
    
    
}

-(BOOL) currentPlayerWon {
    for (Player *player in self.players) {
        if (currentPlayer.score < player.score) {
            return NO;
        }
    }
    return YES;
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
                cell.playerUserName = @"";
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
        cell.backgroundColor = [UIColor lightGrayColor];
        
        cell.layer.borderWidth=1.0f;
        
        cell.layer.borderColor=[UIColor whiteColor].CGColor;
        cell.textLabel.text = text;
        cell.textLabel.textColor = [UIColor blackColor];
        return cell;
    }
    
    return nil;
}

-(void)boardWasTouched:(UITouch *)touch {
    CGPoint someLocation = [touch locationInView: self.view];
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(someLocation.x, someLocation.y, 1, 1)];
    BoardViewCell *cell = [self findClosestCellToView:tempView];
    NSString *text = cell.textLabel.text;
    
    NSIndexPath *indexPath = [self.boardCollectionView indexPathForCell:cell];
    BoardCellDTO *dto =self.board[indexPath.row];
    
    if(_touchToPlay){
        if([self tileIsSelected]){
            [self playTile:_selectedTile atIndexPath:indexPath onCell:cell];
            [_selectedTile makeUnselected];
            _selectedTile = nil;
        }
    }
    
    if (text == nil || [text isEqualToString:@""] || dto.pending == 1) {
    }
    else {
        
    }
    
}

-(void)tossWasTouched:(UITouch *)touch {
    if(_touchToPlay){
        if([self tileIsSelected]){
            TileViewCell *tile = _selectedTile;
            [self clearSelectedTile];
            [self tossTile:tile];
        }
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BoardCellDTO *cellDTO = (BoardCellDTO *)self.board[indexPath.item];
    NSString *currentBoardLetter = ((BoardCellDTO *)self.board[indexPath.item]).text;
    if (collectionView.tag == 1) {
        UICollectionViewCell *cell = [self.boardCollectionView cellForItemAtIndexPath:indexPath];
        if ([currentBoardLetter isEqualToString:@"-"]) {
            
        }
        else {
            TileViewCell *tile = [[TileViewCell alloc] initWithFrame:CGRectMake(collectionView.frame.origin.x + cell.frame.origin.x, collectionView.frame.origin.y + cell.frame.origin.y, TILE_WIDTH, TILE_WIDTH) playerID:cellDTO.playerUserName];
            [self.view addSubview:tile];
            [self.view bringSubviewToFront:tile];
            ((BoardCellDTO *)self.board[indexPath.item]).text = @"-";
            [self.boardCollectionView reloadData];
            
        }
//        [self playTileAtIndexPath:indexPath];
    }
    
    else if (collectionView.tag == 2) {
        self.selectedIndex = indexPath.item;
        [self.tileCollectionView reloadData];
        UICollectionViewCell *cell = [self.tileCollectionView cellForItemAtIndexPath:indexPath];
        [self.view bringSubviewToFront:cell];
    }
}

#pragma mark – UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    TILE_WIDTH = self.boardCollectionView.bounds.size.width/10;
    TILE_HEIGHT = self.boardCollectionView.bounds.size.width/10;

    return CGSizeMake(TILE_WIDTH, TILE_HEIGHT);
}

// 3
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (collectionView.tag == 1) {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    else return UIEdgeInsetsMake(10, 10, 10, 10);
}
-(void) takeTile:(UIView *)tile {
    TileViewCell *theTile = ((TileViewCell *)tile);
    if (currentPlayer.numberOfTiles < STARTING_NUMBER_OF_TILES && !theTile.isPending) {
        [UIView animateWithDuration:0.1 animations:^{
            tile.frame =[[_tileSpaces objectAtIndex:0] CGRectValue];
        }];
        
        
        [_tileSpaces removeObjectAtIndex:0];
        currentPlayer.numberOfTiles++;
        BoardCellDTO *dto = self.board[theTile.indexPath.item];
        dto.text = @"-";
        dto.playerUserName = @"";
        theTile.isNotOnBoard = YES;
        theTile.startPoint = tile.frame.origin;
        theTile.isNotOnBoard = YES;
    }
}
-(BOOL) playTile: (TileViewCell *)tile atIndexPath:(NSIndexPath *)indexPath onCell:(BoardViewCell*)bvc{
    NSLog(@"%ld", (long)indexPath.item);
    NSString *currentBoardLetter = ((BoardCellDTO *)self.board[indexPath.item]).text;
    NSString *currentSelectedLetter = tile.letterLabel.text;
    if ([currentBoardLetter isEqualToString:@"-"]) {
        
        //send update packet
        NSString* message = [NSString stringWithFormat:@"%ld,%@", (long)indexPath.item, currentSelectedLetter];
        [NetworkUtils sendLetterPlayed:message];
        
        //update the board
        BoardCellDTO *dto = self.board[indexPath.item];
        dto.text = currentSelectedLetter;
        dto.playerUserName = [GameConstants getUserName];
        dto.pending = 1;
        [self.boardCollectionView reloadData];
        
        [self removeTileFromCurrentSpot:tile];
        
        CGRect newFrame = CGRectMake(bvc.frame.origin.x + self.boardCollectionView.frame.origin.x, bvc.frame.origin.y+ self.boardCollectionView.frame.origin.y, tile.frame.size.width, tile.frame.size.height);
        tile.frame = newFrame;
        tile.startPoint = newFrame.origin;
        tile.indexPath = indexPath;
        tile.isNotOnBoard = NO;
//        [tile makePending];
        dto.tvc = tile;
        return NO;
    }
    return NO;
}
-(void) removeTile:(TileViewCell *)tile {
    [self removeTileFromCurrentSpot:tile];
    [tile removeFromSuperview];
}
-(void) removeTileFromCurrentSpot:(TileViewCell *)tile {
    if (tile.isNotOnBoard) {
        CGRect rec = CGRectMake(tile.startPoint.x, tile.startPoint.y, tile.frame.size.width, tile.frame.size.height);
        currentPlayer.numberOfTiles--;
        [self.tileSpaces addObject:[NSValue valueWithCGRect:rec]];
    }
    else {
        BoardCellDTO *dto = self.board[tile.indexPath.item];
        dto.text = @"-";
        dto.tvc = nil;
        dto.playerUserName = @"";
        
        //send removed tile update
        NSString* message = [NSString stringWithFormat:@"%ld", (long)tile.indexPath.item];
        [NetworkUtils sendLetterRemoved:message];
    }
}

-(void)tileDidMove:(UIView *)tile {
    [self unselectAllCells];
    BoardViewCell *closestCell = [self findClosestCellToView:tile];
    if (closestCell != nil) {
        closestCell.layer.borderWidth = 2.0f;
        closestCell.layer.borderColor = [UIColor blackColor].CGColor;
    }
}

- (IBAction)touchUpSubmit:(id)sender {
    dispatch_queue_t otherQ = dispatch_queue_create("check_board", NULL);
    dispatch_async(otherQ, ^{
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
                
            }
            else {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Board" message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
            }
            
            
        } else {
            dispatch_queue_t mainQ = dispatch_get_main_queue();
            dispatch_async(mainQ, ^{
                [self sendBoardInfo];
                if (currentPlayer.numberOfTiles < STARTING_NUMBER_OF_TILES) {
                    int num = STARTING_NUMBER_OF_TILES - currentPlayer.numberOfTiles;
                    for (int i = 0; i < num; i++) {
                        [self addTile];
                    }
                }
                [self finalizePendingEnemyTilesForPlayer:[GameConstants getUserName]];
                //[self updateScores];
                [NetworkUtils sendWordPlayed];
            });
        }
    });
}

-(void) addTile {
    TileViewCell *newTile = [[TileViewCell alloc] initWithFrame:[[_tileSpaces objectAtIndex:0] CGRectValue] playerID:[GameConstants getUserName]];
        NSLog(@"%d", currentPlayer.numberOfTiles);
    
    [_tileSpaces removeObjectAtIndex:0];
    
    [self.view addSubview:newTile];
    currentPlayer.numberOfTiles++;
}

-(void) sendBoardInfo {
    // TODO
}

-(BOOL) tileDidFinishMoving:(UIView *)tile {
    [self unselectAllCells];
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
        [self takeTile:tileCell];
    }
    return NO;
}

-(BOOL) isThrowingAway:(TileViewCell *)tile {
    float curDist = [self view:tile DistanceToView:_tossView];
    if (tile.isNotOnBoard && curDist < tile.frame.size.height/2 + _tossView.frame.size.height/2) {
        return YES;
    }
    return NO;
}

-(void) tossTile:(TileViewCell *)tile {
    [self removeTile:tile];
    [self addTile];
}

-(void) unselectAllCells {
    for (UICollectionViewCell *cell in _boardCollectionView.visibleCells) {
        cell.layer.borderWidth = 1.0f;
        cell.layer.borderColor = [UIColor whiteColor].CGColor;
    }
}

-(BoardViewCell *) findClosestCellToView:(UIView *)view {
    float minDist = -1;
    BoardViewCell *closestCell = nil;
    for (BoardViewCell *cell in _boardCollectionView.visibleCells) {
        float curDist = [self view:view DistanceToView:cell];
        if (curDist < view.frame.size.height/2 + cell.frame.size.height/2) {
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

-(void) updateScoresForPlayer:(NSString *)player {
    int pointsEarned = [self.boardChecker calculateScoreForBoard:self.board];
    NSNumber *oldScore = [self.playerScores valueForKey:player];
    int newScore = pointsEarned + [oldScore intValue];
    [self.playerScores setValue:[NSNumber numberWithInt:newScore] forKey:player];
    [self refreshScoresText];
}

-(void) refreshScoresText {
    NSString *scoresString = @"SCORES:\n";
    for (NSString *playerName in self.playerScores.allKeys) {
        NSNumber *num = [self.playerScores valueForKey:playerName];
        scoresString = [scoresString stringByAppendingFormat:@"%@: %d\n", playerName, [num intValue]];
    }
    self.scores.text = scoresString;
}

//-(int) calculateScoreForPlayer:(NSString *)playerUserName {
//    int playerScore = 0;
//    for (int i = 0; i < [self.board count]; i++) {
//        BoardCellDTO *cell = [self.board objectAtIndex:i];
//        if ([cell.playerUserName isEqualToString:playerUserName]) {
//            playerScore++;
//        }
//    }
//    
//    return playerScore;
//}

////////////////////
// Begin Networking Calls
////////////////////

-(void)addPlayer:(NSString *)playerUserName {
    Player *player = [[Player alloc] init];
    player.userName = playerUserName;
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

-(void)placeEnemyPendingLetter:(NSString *)letter atIndexPath:(NSIndexPath *)indexPath forEnemy:(NSString *)enemyID {
    ((BoardCellDTO *)self.board[indexPath.item]).pending = 1;
    [self placeEnemyLetter:letter atIndexPath:indexPath forEnemy:(NSString *)enemyID];
}

-(void)placeEnemyLetter:(NSString *)letter atIndexPath:(NSIndexPath *)indexPath forEnemy:(NSString *)enemyID{
    BoardCellDTO *dto =self.board[indexPath.item];
    dto.text = letter;
    dto.playerUserName = enemyID;

    UICollectionViewCell *cell = [self.boardCollectionView cellForItemAtIndexPath:indexPath];
    CGRect frame = CGRectMake(cell.frame.origin.x + self.boardCollectionView.frame.origin.x, cell.frame.origin.y + self.boardCollectionView.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
    TileViewCell *tvc = [[TileViewCell alloc] initWithFrame:frame letter:letter playerUserName:dto.playerUserName];
    [tvc makePending];
    [self.view addSubview:tvc];
    dto.tvc = tvc;
}

-(void)finalizePendingEnemyTilesForPlayer:(NSString *)player {
    [self updateScoresForPlayer:player];
    if (currentPlayer.numberOfTiles < STARTING_NUMBER_OF_TILES) {
        int num = STARTING_NUMBER_OF_TILES - currentPlayer.numberOfTiles;
        for (int i = 0; i < num; i++) {
            [self addTile];
        }
    }
    for (int i = 0; i < [self.board count]; i++) {
        BoardCellDTO *cellDTO = self.board[i];
        if(cellDTO.pending == 1){
            cellDTO.pending = 0;
            [cellDTO.tvc makeFinalized];
        }
    }
    [self.boardCollectionView reloadData];
}

-(void)removeEnemyLetterAtIndexPath:(NSIndexPath *)indexPath {
    BoardCellDTO *dto =self.board[indexPath.item];
    dto.text = @"-";
    dto.playerUserName = @"";
    
    if(dto.tvc != nil){
        [dto.tvc removeFromSuperview];
    }
    
    dto.tvc = nil;
    [self.boardCollectionView reloadData];
}

-(void)leaveGame{
    [[WarpClient getInstance] disconnect];
}


////////////////////
// End Networking Calls
////////////////////

@end
