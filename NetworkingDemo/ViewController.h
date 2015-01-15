//
//  ViewController.h
//  NetworkingDemo
//
//  Created by Margaret Kelley on 12/25/14.
//  Copyright (c) 2014 Margaret Kelley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AppWarp_iOS_SDK/AppWarp_iOS_SDK.h>
@interface ViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

+(ViewController *)sharedViewController;
-(void)updateCellForIndexPath:(NSIndexPath *)indexPath withLetter:(NSString *)letter;
-(void)tileDidMove:(UIView *)tile;
-(BOOL) tileDidFinishMoving:(UIView *)tile;
-(void)boardWasTouched:(UITouch *)touch;
- (IBAction)touchUpSubmit:(id)sender;
@end

