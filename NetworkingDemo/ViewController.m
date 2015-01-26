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
@end

@implementation ViewController

static ViewController *vc;
Player *player;
int numPlayers = 2;
int minutes;
int seconds;

- (void)viewDidLoad {
    
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
    player = [[Player alloc] init];
    minutes = 2;
    seconds = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCounter:) userInfo:nil repeats:YES];

    for (int i = 0; i < STARTING_NUMBER_OF_TILES; i++) {
        CGRect rec = CGRectMake(player.numberOfTiles * TILE_WIDTH * 2 + self.boardCollectionView.frame.origin.x, 560, TILE_WIDTH, TILE_WIDTH);
        [self.tileSpaces addObject:[NSValue valueWithCGRect:rec]];
        [self addTile];
    }
    
    
    [self updateScores];
    
}

- (void)updateCounter:(NSTimer *)theTimer {
    if (seconds > 0) {
        seconds--;
    }
    else if (minutes > 0) {
        seconds = 59;
        minutes--;
    }
    self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
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
                cell.player = 0;
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
        if ([text isEqualToString:@"-"]) {
            text = @"";
            cell.backgroundColor = [UIColor lightGrayColor];
        }
        else {
            cell.backgroundColor = [UIColor greenColor];
            cell.player = 1;
        }

        //check if this was an enemy played tile
        BoardCellDTO *dto =self.board[indexPath.row];
        if(dto.player == 2){
            cell.player = 1;
            if(dto.pending == 1){
                cell.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:0/255.0 blue:0/255.0 alpha:0.4];
            } else {
                cell.backgroundColor = [UIColor redColor];
            }
        }
        
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
    
    if (text == nil || [text isEqualToString:@""] || dto.pending == 1) {
    }
    else {
        cell.textLabel.text = @"";
        cell.backgroundColor = [UIColor lightGrayColor];
        
        TileViewCell *tile = [[TileViewCell alloc] initWithFrame:CGRectMake(someLocation.x -TILE_WIDTH/2, someLocation.y - TILE_WIDTH/2, TILE_WIDTH, TILE_WIDTH) letter:((BoardCellDTO *)self.board[indexPath.row]).text];
        [self.view addSubview:tile];

        dto.text = @"-";
        dto.player = 0;
        [self.boardCollectionView reloadData];
        
        //update other players that letter was removed
        NSString* message = [NSString stringWithFormat:@"%ld", (long)indexPath.item];
        [NetworkUtils sendLetterRemoved:message];
        
        [tile touchesBegan:[[NSSet alloc] initWithObjects:touch, nil] withEvent:nil];
        player.numberOfTiles++;
    }
    
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *currentBoardLetter = ((BoardCellDTO *)self.board[indexPath.item]).text;
    if (collectionView.tag == 1) {
        UICollectionViewCell *cell = [self.boardCollectionView cellForItemAtIndexPath:indexPath];
        if ([currentBoardLetter isEqualToString:@"-"]) {
            
        }
        else {
            TileViewCell *tile = [[TileViewCell alloc] initWithFrame:CGRectMake(collectionView.frame.origin.x + cell.frame.origin.x, collectionView.frame.origin.y + cell.frame.origin.y, TILE_WIDTH, TILE_WIDTH)];
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
    
    if (collectionView.tag == 1) {
        int width = self.boardCollectionView.frame.size.width/10;
        int height = self.boardCollectionView.frame.size.height/10;
        return CGSizeMake(width, height);
    }
    if (collectionView.tag == 2) {
        int width = (self.tileCollectionView.frame.size.width/8) - 20;
        int height = self.tileCollectionView.frame.size.height - 20;
        return CGSizeMake(width, height);
    }
    return CGSizeMake(10, 10);
}

// 3
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (collectionView.tag == 1) {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    else return UIEdgeInsetsMake(10, 10, 10, 10);
}

-(BOOL) playTile: (TileViewCell *)tile atIndexPath:(NSIndexPath *)indexPath {
    NSString *currentBoardLetter = ((BoardCellDTO *)self.board[indexPath.item]).text;
    NSString *currentSelectedLetter = tile.letterLabel.text;
    if ([currentBoardLetter isEqualToString:@"-"]) {
        
        //send update packet
        NSString* message = [NSString stringWithFormat:@"%ld,%@", (long)indexPath.item, currentSelectedLetter];
        [NetworkUtils sendLetterPlayed:message];
        
        //update the board
        BoardCellDTO *dto =self.board[indexPath.item];
        dto.text = currentSelectedLetter;
        dto.player = 1;
        [self.boardCollectionView reloadData];
        
        player.numberOfTiles--;
        
        if (tile.shouldReplace) {
            CGRect rec = CGRectMake(tile.startPoint.x, tile.startPoint.y, tile.frame.size.width, tile.frame.size.height);
            [self.tileSpaces addObject:[NSValue valueWithCGRect:rec]];
        }
        return YES;
    }
    return NO;
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
        NSArray *invalidWordsOnBoard = [BoardChecker checkBoardState:self.board];
        if ([invalidWordsOnBoard count] > 0) {
            
            NSString *alertMessage = @"Found the following invalid words: ";
            alertMessage = [alertMessage stringByAppendingString:[invalidWordsOnBoard componentsJoinedByString:@", "]];
            
            //tion:ok]; // add action to uialertcontroller
            
        } else {
            dispatch_queue_t mainQ = dispatch_get_main_queue();
            dispatch_async(mainQ, ^{
                [self sendBoardInfo];
                if (player.numberOfTiles < STARTING_NUMBER_OF_TILES) {
                    int num = STARTING_NUMBER_OF_TILES - player.numberOfTiles;
                    for (int i = 0; i < num; i++) {
                        [self addTile];
                    }
                }
                [self updateScores];
                [NetworkUtils sendWordPlayed];
            });
        }
    });
}

-(void) addTile {
    
    TileViewCell *newTile = [[TileViewCell alloc] initWithFrame:[[_tileSpaces objectAtIndex:0]CGRectValue]];
    [_tileSpaces removeObjectAtIndex:0];
    
    [self.view addSubview:newTile];
    player.numberOfTiles++;
}

-(void) sendBoardInfo {
    // TODO
}

-(BOOL) tileDidFinishMoving:(UIView *)tile {
    [self unselectAllCells];
    BoardViewCell *closestCell = [self findClosestCellToView:tile];
    if (closestCell) {
        closestCell.tag = 1;
        return [self playTile:(TileViewCell*)tile atIndexPath:[_boardCollectionView indexPathForCell:closestCell]];
    }
    return NO;
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

-(void) updateScores {
    NSString *scoresString = @"SCORES:\n";
    
    for (int i = 1; i <= numPlayers; i++) {
        scoresString = [scoresString stringByAppendingFormat:@"PLAYER %d: %d\n", i, [self calculateScoreForPlayer:i]];
    }
    _scores.text = scoresString;
}

-(int) calculateScoreForPlayer:(int)playerNum {
    int playerScore = 0;
    for (int i = 0; i < [self.board count]; i++) {
        BoardCellDTO *cell = [self.board objectAtIndex:i];
        if (cell.player == playerNum) {
            playerScore++;
        }
    }
    
    return playerScore;
}

////////////////////
// Begin Networking Calls
////////////////////

-(void)placeEnemyPendingLetter:(NSString *)letter atIndexPath:(NSIndexPath *)indexPath {
    ((BoardCellDTO *)self.board[indexPath.item]).pending = 1;
    [self placeEnemyLetter:letter atIndexPath:indexPath];
}

-(void)placeEnemyFinializedLetter:(NSString *)letter atIndexPath:(NSIndexPath *)indexPath{
    ((BoardCellDTO *)self.board[indexPath.item]).pending = 0;
    [self placeEnemyLetter:letter atIndexPath:indexPath];
}

-(void)placeEnemyLetter:(NSString *)letter atIndexPath:(NSIndexPath *)indexPath{
    BoardCellDTO *dto =self.board[indexPath.item];
    dto.text = letter;
    dto.player = 2;
    [self.boardCollectionView reloadData];
}

-(void)finalizePendingEnemyTiles {
    for (int i = 0; i < [self.board count]; i++) {
        BoardCellDTO *cellDTO = self.board[i];
        if(cellDTO.pending == 1){
            cellDTO.pending = 0;
        }
    }
    [self.boardCollectionView reloadData];
}

-(void)removeEnemyLetterAtIndexPath:(NSIndexPath *)indexPath {
    BoardCellDTO *dto =self.board[indexPath.item];
    dto.text = @"-";
    dto.player = -1;
    [self.boardCollectionView reloadData];
}

////////////////////
// End Networking Calls
////////////////////

@end
