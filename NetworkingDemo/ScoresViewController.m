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
@property (strong, nonatomic) NSMutableArray *scoreStrings;

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
    self.highScoresTextView.text = @"";
    
    // Get the high scores from Parse
    PFQuery *query = [PFQuery queryWithClassName:@"GameScore"];
    query.limit = 20;
    [query orderByDescending:@"score"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
            int i = 1;
            for (PFObject *object in objects) {
                NSLog(@"%@", object.objectId);
                NSNumber *score = object[@"score"];
                [self.scoreStrings addObject:[NSString stringWithFormat:@"%d. %@: %d\n", i, object[@"playerName"], [score intValue]]];
                i++;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshView];
            });
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    //[self.highScoresTextView setText: @"1. David - 15000 \n 2. Kyle - 14000 \n 3. Margaret - 1000"];
}

-(void)refreshView {
    for (NSString *string in self.scoreStrings) {
        [self.highScoresTextView setText:[self.highScoresTextView.text stringByAppendingString:string]];
    }
}

@end
