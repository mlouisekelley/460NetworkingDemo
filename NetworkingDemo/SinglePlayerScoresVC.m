//
//  SinglePlayerScoresVC.m
//  WordPlay
//
//  Created by Margaret Kelley on 4/1/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//
#import <Parse/Parse.h>
#import "SinglePlayerScoresVC.h"

@implementation SinglePlayerScoresVC

-(void)viewDidLoad {
    [super viewDidLoad];
}

-(void)executeQuery {
    // Get the high scores from Parse
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

@end
