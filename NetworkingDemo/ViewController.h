//
//  ViewController.h
//  NetworkingDemo
//
//  Created by Margaret Kelley on 12/25/14.
//  Copyright (c) 2014 Margaret Kelley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AppWarp_iOS_SDK/AppWarp_iOS_SDK.h>
#import "NetworkUtils.h"
#import "TileViewCell.h"
@interface ViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UITextView *scores;
@property (strong, nonatomic) IBOutlet UICollectionView *boardCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIView *tossView;
@property (nonatomic) BOOL touchToPlay;

+(ViewController *)sharedViewController;
-(void)tileDidMove:(UIView *)tile;
-(BOOL) tileDidFinishMoving:(UIView *)tile;
-(void)boardWasTouched:(UITouch *)touch;
- (IBAction)touchUpSubmit:(id)sender;
-(void)placeEnemyPendingLetter:(NSString *)letter atIndexPath:(NSIndexPath *)indexPath forEnemy:(NSString *)enemyID;
-(void)removeEnemyLetterAtIndexPath:(NSIndexPath *)indexPath;
-(void)finalizePendingEnemyTiles;
-(void)addPlayer:(NSString *)playerUserName;
-(void)updatePlayerList:(NSArray *)currentPlayers;
-(BOOL)tileIsSelected;
-(void)setSelectedTile:(TileViewCell *)tile;
-(void)clearSelectedTile;
-(void)takeTile:(UIView *)tile;
@end

