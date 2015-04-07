//
//  EndGameDialog.h
//  WordPlay
//
//  Created by David A Nichol on 4/6/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface  EndGameDialog: UIView
@property (weak, nonatomic) IBOutlet UILabel *finalScore;
@property (weak, nonatomic) IBOutlet UILabel *pointsSecond;
@property (weak, nonatomic) IBOutlet UILabel *wordsSecond;
@property (weak, nonatomic) IBOutlet UILabel *highestScoringWord;
@property (weak, nonatomic) IBOutlet UILabel *avgScore;
@property (weak, nonatomic) IBOutlet UILabel *highScore;

- (IBAction)touchHome:(id)sender;
- (IBAction)touchRematch:(id)sender;
@end
