//
//  ScoresViewController.m
//  WordPlay
//
//  Created by Margaret Kelley on 3/15/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//

#import "ScoresViewController.h"

@interface ScoresViewController ()

@property (strong, nonatomic) IBOutlet UITextView *highScoresTextView;

@end


@implementation ScoresViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self.highScoresTextView setText: @"1. David - 15000 \n 2. Kyle - 14000 \n 3. Margaret - 1000"];
}

@end
