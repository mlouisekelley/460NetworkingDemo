//
//  ViewController.m
//  NetworkingDemo
//
//  Created by Margaret Kelley on 12/25/14.
//  Copyright (c) 2014 Margaret Kelley. All rights reserved.
//

#import "ViewController.h"
#import "BoardViewCell.h"
#import "TileViewCell.h"
#import "GameConstants.h"
#import "Player.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *boardCollectionView;
@property (strong, nonatomic) IBOutlet UICollectionView *tileCollectionView;
@property (strong, nonatomic) NSMutableArray *board;
@property (strong, nonatomic) NSMutableArray *tiles;
@property (nonatomic) NSInteger selectedIndex;
@end

@implementation ViewController

static ViewController *vc;
Player *player;

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
        NSArray *arr = @[@"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-",
                         @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-",
                         @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-",
                         @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-",
                         @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-",
                         @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-",
                         @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-",
                         @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-",
                         @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-",
                         @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-", @"-"];
        _board = [[NSMutableArray alloc] initWithArray:arr];
    }
    return _board;
}

- (NSArray *)tiles
{
    if (!_tiles) {
        NSArray *arr = @[@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h"];
        _tiles = [[NSMutableArray alloc] initWithArray:arr];
    }
    return _tiles;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.boardCollectionView setTag:1];
    [self.tileCollectionView setTag:2];

    [self.boardCollectionView reloadData];
    self.boardCollectionView.dataSource = self;
    self.boardCollectionView.delegate = self;
    
    [self.tileCollectionView reloadData];
    self.tileCollectionView.dataSource = self;
    self.tileCollectionView.delegate = self;
    
    vc = self;
    player = [[Player alloc] init];
    
    for (int i = 0; i < STARTING_NUMBER_OF_TILES; i++) {
        [self addTile];
    }
    
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

-(void)updateCellForIndexPath:(NSIndexPath *)indexPath withLetter:(NSString *)letter
{
    self.board[indexPath.item] = [letter stringByAppendingString:@"*"];
    NSArray* indicies = @[indexPath];
    [self.boardCollectionView reloadItemsAtIndexPaths:indicies];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.tag == 1) {
        //use self.board to determine how the board looks
        BoardViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"board cell" forIndexPath:indexPath];
        NSString *text = [self.board objectAtIndex:indexPath.item];
        if ([text isEqualToString:@"-"]) {
            text = @"";
            cell.backgroundColor = [UIColor lightGrayColor];
        }
        else {
            if([cell.backgroundColor isEqual:[UIColor lightGrayColor]]){
                //Send chat update with position of letters added
                NSLog(@"%ld", (long)indexPath.item);

            }
            cell.backgroundColor = [UIColor greenColor];
        }
        
        //check to see if the character is an from opponent
        if([text rangeOfString:[NSString stringWithFormat:@"%c",'*']].location != NSNotFound){
            //enemy letter
            cell.backgroundColor = [UIColor redColor];
            text = [text substringWithRange:NSMakeRange(0, 1)];
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
    if ([text isEqualToString:@""]) {
    }
    else {
        cell.textLabel.text = @"";
        cell.backgroundColor = [UIColor lightGrayColor];
        NSIndexPath *indexPath = [self.boardCollectionView indexPathForCell:cell];
        TileViewCell *tile = [[TileViewCell alloc] initWithFrame:CGRectMake(someLocation.x -TILE_WIDTH/2, someLocation.y - TILE_WIDTH/2, TILE_WIDTH, TILE_WIDTH) letter:self.board [indexPath.row]];
        [self.view addSubview:tile];
        self.board[indexPath.row] = @"-";
        [self.boardCollectionView reloadData];
        [tile touchesBegan:[[NSSet alloc] initWithObjects:touch, nil] withEvent:nil];
        player.numberOfTiles++;
    }
    
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *currentBoardLetter = self.board[indexPath.item];
    if (collectionView.tag == 1) {
        UICollectionViewCell *cell = [self.boardCollectionView cellForItemAtIndexPath:indexPath];
        if ([currentBoardLetter isEqualToString:@"-"]) {
            
        }
        else {
            TileViewCell *tile = [[TileViewCell alloc] initWithFrame:CGRectMake(collectionView.frame.origin.x + cell.frame.origin.x, collectionView.frame.origin.y + cell.frame.origin.y, TILE_WIDTH, TILE_WIDTH)];
            [self.view addSubview:tile];
            [self.view bringSubviewToFront:tile];
            self.board[indexPath.item] = @"-";
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
    NSString *currentBoardLetter = self.board[indexPath.item];
    NSString *currentSelectedLetter = tile.letterLabel.text;
    if ([currentBoardLetter isEqualToString:@"-"]) {
        
        //send update packet
        NSString* message = [NSString stringWithFormat:@"%ld,%@", (long)indexPath.item, currentSelectedLetter];
        [[WarpClient getInstance] sendChat:message];
        
        //update the board
        self.board[indexPath.item] = currentSelectedLetter;
        [self.boardCollectionView reloadData];
        
        player.numberOfTiles--;
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
    if ([self isBoardValid]) {
        [self sendBoardInfo];
        if (player.numberOfTiles < STARTING_NUMBER_OF_TILES) {
            int num = STARTING_NUMBER_OF_TILES - player.numberOfTiles;
            for (int i = 0; i < num; i++) {
                [self addTile];
            }
        }
    }
}

-(void) addTile {
    TileViewCell *newTile = [[TileViewCell alloc] initWithFrame:CGRectMake(player.numberOfTiles * TILE_WIDTH * 2 + self.boardCollectionView.frame.origin.x, 560, TILE_WIDTH, TILE_WIDTH)];
    [self.view addSubview:newTile];
    player.numberOfTiles++;
}

-(void) sendBoardInfo {
    // TODO
}

-(BOOL) isBoardValid {
    return YES;
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

@end
