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
    self.highScoresTextView.text = [self.highScoresTextView.text stringByAppendingString:@"\n"];
    
    self.highScoresTextView.text = @"Multi-player High Scores:\n";
    PFQuery *query = [PFQuery queryWithClassName:@"GameScore"];
    [self.scoreStrings removeAllObjects];
    query.limit = 20;
    [query orderByDescending:@"score"];
    [query whereKey:@"numPlayers" greaterThan:@1];
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
}

- (IBAction)multiPlayerTouched:(id)sender {
    self.highScoresTextView.text = @"Multi-player High Scores:\n";
    PFQuery *query = [PFQuery queryWithClassName:@"GameScore"];
    [self.scoreStrings removeAllObjects];
    query.limit = 20;
    [query orderByDescending:@"score"];
    [query whereKey:@"numPlayers" greaterThan:@1];
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
}

- (IBAction)singlePlayerTouched:(id)sender {
    self.highScoresTextView.text = @"Single player High Scores:\n";
    [self.scoreStrings removeAllObjects];
    PFQuery *query = [PFQuery queryWithClassName:@"GameScore"];
    query.limit = 20;
    [query orderByDescending:@"score"];
    [query whereKey:@"numPlayers" equalTo:@1];
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
}

-(void)refreshView {
    for (NSString *string in self.scoreStrings) {
        self.highScoresTextView.text = [self.highScoresTextView.text stringByAppendingString:string]    ;
    }
}

@end
