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

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *boardCollectionView;
@property (strong, nonatomic) IBOutlet UICollectionView *tileCollectionView;
@property (strong, nonatomic) NSMutableArray *board;
@property (strong, nonatomic) NSMutableArray *tiles;
@property (nonatomic) NSInteger selectedIndex;

@end

@implementation ViewController

static ViewController *vc;

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
    else if (collectionView.tag == 2) {
//        return [self.tiles count];
    }
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(void)updateCellForIndexPath:(NSIndexPath *)indexPath withLetter:(NSString *)letter
{
    //BoardViewCell *cell = [self.boardCollectionView dequeueReusableCellWithReuseIdentifier:@"board cell" forIndexPath:indexPath];
    self.board[indexPath.item] = [letter stringByAppendingString:@"*"];
    //cell.backgroundColor = [UIColor redColor];
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
                NSString* message = [NSString stringWithFormat:@"%ld,%@", (long)indexPath.item, text];
                [[WarpClient getInstance] sendChat:message];
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
    
    if (collectionView.tag == 2) {
//        //use self.tiles to determine how the tiles look
//        TileViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"user cell" forIndexPath:indexPath];
//        if (indexPath.item == self.selectedIndex) {
//            cell.layer.borderWidth = 2.0f;
//            cell.layer.borderColor = [UIColor blackColor].CGColor;
//        }
//        else {
//            cell.layer.borderWidth = 0.0f;
//            cell.layer.borderColor = [UIColor clearColor].CGColor;
//        }
//        cell.letterLabel.text = [self.tiles objectAtIndex:indexPath.item];
//        cell.letterLabel.textColor = [UIColor blackColor];
//        return cell;
        
    }
    return nil;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.tag == 1) {
        [self playTileAtIndexPath:indexPath];
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

-(void) playTileAtIndexPath:(NSIndexPath *)indexPath {
    NSString *currentBoardLetter = self.board[indexPath.item];
    NSString *currentSelectedLetter = self.tiles[self.selectedIndex];
    if ([currentBoardLetter isEqualToString:@"-"]) {
        //update the board
        self.board[indexPath.item] = currentSelectedLetter;
        [self.boardCollectionView reloadData];
        
        //update the user's tiles
        [self.tiles removeObjectAtIndex:self.selectedIndex];
        [self.tileCollectionView reloadData];
    }
}

-(void)tileDidMove:(UIView *)tile {
    NSLog(@"X: %f Y: %f", tile.frame.origin.x, tile.frame.origin.y);
    [self unselectAllCells];
    BoardViewCell *closestCell = [self findClosestCellToView:tile];
    if (closestCell != nil) {
        closestCell.layer.borderWidth = 2.0f;
        closestCell.layer.borderColor = [UIColor blackColor].CGColor;
    }
}

-(BOOL) tileDidFinishMoving:(UIView *)tile {
    BoardViewCell *closestCell = [self findClosestCellToView:tile];
    if (closestCell) {
        closestCell.tag = 1;
        [self playTileAtIndexPath:[_boardCollectionView indexPathForCell:closestCell]];
        return YES;
    }
    return NO;
}
-(void) unselectAllCells {
    for (UICollectionViewCell *cell in _boardCollectionView.visibleCells) {
        cell.layer.borderWidth = 0.0f;
        cell.layer.borderColor = [UIColor whiteColor].CGColor;
    }
}

-(BoardViewCell *) findClosestCellToView:(UIView *)view {
    float minDist = -1;
    BoardViewCell *closestCell = nil;
    for (BoardViewCell *cell in _boardCollectionView.visibleCells) {
        float curDist = [self view:view DistanceToView:cell];
        if (curDist < view.frame.size.height * 2) {
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
