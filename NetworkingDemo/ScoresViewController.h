//
//  ScoresViewController.h
//  WordPlay
//
//  Created by Margaret Kelley on 3/15/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoresViewController : UIViewController
@property (strong, nonatomic) NSMutableArray *scoreStrings;
- (void)executeQuery; //to be implemented by inheriting classes
- (void)refreshView;

@end
