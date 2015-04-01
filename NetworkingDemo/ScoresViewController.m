//
//  ScoresViewController.m
//  WordPlay
//
//  Created by Margaret Kelley on 3/15/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//
#import <Parse/Parse.h>
#import "ScoresViewController.h"

@interface ScoresViewController ()

@property (strong, nonatomic) IBOutlet UITextView *highScoresTextView;

@end


@implementation ScoresViewController

-(NSMutableArray *)scoreStrings
{
    if (!_scoreStrings) {
        _scoreStrings = [[NSMutableArray alloc] init];
    }
    return _scoreStrings;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self.highScoresTextView setText:[self.highScoresTextView.text stringByAppendingString:@"\n"]];
    
    [self executeQuery];
    
    //[self.highScoresTextView setText: @"1. David - 15000 \n 2. Kyle - 14000 \n 3. Margaret - 1000"];
}

-(void)executeQuery {
    //do nothing here
}

-(void)refreshView {
    for (NSString *string in self.scoreStrings) {
        [self.highScoresTextView setText:[self.highScoresTextView.text stringByAppendingString:string]];
    }
}

@end
