//
//  BoardChecker.m
//  NetworkingDemo
//
//  Created by Margaret Kelley on 1/14/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//

#import "BoardChecker.h"
#import "GameConstants.h"
#import "BoardCellDTO.h"

@interface BoardChecker()

@property (nonatomic, strong) NSMutableDictionary *alreadyCheckedWords;
@property (nonatomic, strong) NSDictionary *scrabbleDict;

@end

@implementation BoardChecker

- (id) initWithScrabbleDict {
    self = [super init];
    NSMutableDictionary *wordDict = [[NSMutableDictionary alloc] init];
    
    //open the file and read each line into an array
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"scrabble_words" ofType:@"txt"];
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
    
    if (error)
        NSLog(@"Error reading file: %@", error.localizedDescription);
    
    
    NSArray *listArray = [fileContents componentsSeparatedByString:@"\n"];
    NSLog(@"items = %d", [listArray count]);
    
    for (NSString *word in listArray) {
        if ([word length] > 1) {
            [wordDict setValue:@"" forKey:word];
        }
    }
    
    self.scrabbleDict = wordDict;
    
    return self;
}


- (NSMutableDictionary *) alreadyCheckedWords {
    if (!_alreadyCheckedWords) {
        _alreadyCheckedWords = [[NSMutableDictionary alloc] init];
    }
    return _alreadyCheckedWords;
}

/*
 Note: this method runs synchronous URL requests, so be sure to call it off the main queue
 This checks the board for incorrect words. If the board is valid, the returned array
 will be empty.
 */
-(NSArray *)checkBoardState:(NSArray *)board {
    
    NSMutableArray *incorrectWords = [[NSMutableArray alloc] init];
    NSMutableArray *notConnectedWords = [[NSMutableArray alloc] init];
    for (int i = 0; i<[board count]; i++) {
        BoardCellDTO *cellDTO = board[i];
        NSString *space = cellDTO.text;
        if (![self isBlank:space] && [self shouldCheckCellDTO:cellDTO]) {
            BoardCellDTO *up = (i - 10) >= 0 ? board[i - 10] : nil;
            BoardCellDTO *left = (i - 1) >= 0 ? board[i - 1] : nil;
            BoardCellDTO *right = (i + 1)%10 > 0 ? board[i + 1] : nil;
            BoardCellDTO *down = (i + 10) < 100 ? board[i + 10] : nil;
            if (![self shouldCheckCellDTO:up] && [self shouldCheckCellDTO:down]) {
                BOOL wordIsConnected = NO;
                if (cellDTO.tvc.isFinalized || [cellDTO.tvc.pid isEqualToString:@"stone"]) {
                    wordIsConnected = YES;
                }
                NSString *word = space;
                int currLetterIndex = i + 10;
                BoardCellDTO *currentDTO = board[currLetterIndex];
                while ([self shouldCheckCellDTO:currentDTO] && currLetterIndex < 100) {
                    word = [word stringByAppendingString:currentDTO.text];
                    if ([self cellIsConnected:currentDTO index:currLetterIndex board:board]) {
                        wordIsConnected = YES;
                    }
                    currLetterIndex += 10;
                    currentDTO = currLetterIndex < 100 ? board[currLetterIndex] : nil;
                    
                }
                if (!wordIsConnected) {
                    [notConnectedWords addObject:word];
                }
                if (![self isValid:word] || [word length] == 1) {
                    [incorrectWords addObject:word];
                }
            }
            
            else if (![self shouldCheckCellDTO:left] && [self shouldCheckCellDTO:right]) {
                BOOL wordIsConnected = NO;
                if (cellDTO.tvc.isFinalized || [cellDTO.tvc.pid isEqualToString:@"stone"]) {
                    wordIsConnected = YES;
                }
                NSString *word = space;
                int currLetterIndex = i + 1;
                BoardCellDTO *currentDTO = board[currLetterIndex];
                while ([self shouldCheckCellDTO:currentDTO] && (currLetterIndex%10 > 0)) {
                    word = [word stringByAppendingString:currentDTO.text];
                    if ([self cellIsConnected:currentDTO index:currLetterIndex board:board]) {
                        wordIsConnected = YES;
                    }
                    currLetterIndex++;
                    currentDTO = currLetterIndex%10>0 ? board[currLetterIndex] : nil;
                    
                }
                if (!wordIsConnected) {
                    [notConnectedWords addObject:word];
                }
                if (![self isValid:word] || [word length] == 1) {
                    [incorrectWords addObject:word];
                }
            }
            
            else if ([self isBlank:up.text] && [self isBlank:left.text] && [self isBlank:right.text] && [self isBlank:down.text] && [cellDTO.tvc.pid isEqualToString:[GameConstants getUserName]]){
                [incorrectWords addObject:cellDTO.text];
            }
            
        }
    }
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    [returnArray addObject:incorrectWords];
    [returnArray addObject:notConnectedWords];
    return returnArray;
}

-(BOOL)cellIsConnected:(BoardCellDTO *)cellDTO index:(int)i board:(NSArray *)board
{
    BoardCellDTO *up = (i - 10) >= 0 ? board[i - 10] : nil;
    BoardCellDTO *left = (i - 1) >= 0 ? board[i - 1] : nil;
    BoardCellDTO *right = (i + 1)%10 > 0 ? board[i + 1] : nil;
    BoardCellDTO *down = (i + 10) < 100 ? board[i + 10] : nil;
    
    if (cellDTO.tvc.isFinalized || [cellDTO.tvc.pid isEqualToString:@"stone"]) {
        return YES;
    }
    
    if (up != nil) {
        if (up.tvc.isFinalized || [up.tvc.pid isEqualToString:@"stone"]) {
            return YES;
        }
    }
    
    if (left != nil) {
        if (left.tvc.isFinalized || [left.tvc.pid isEqualToString:@"stone"]) {
            return YES;
        }
    }
    
    if (right != nil) {
        if (right.tvc.isFinalized || [right.tvc.pid isEqualToString:@"stone"]) {
            return YES;
        }
    }
    
    if (down != nil) {
        if (down.tvc.isFinalized || [down.tvc.pid isEqualToString:@"stone"]) {
            return YES;
        }
    }
    
    return NO;
    
}

-(NSUInteger)calculateScoreForBoard:(NSArray *)board andPlayer:(NSString *)player {
    NSUInteger count = 0;
    
    for (int i = 0; i<[board count]; i++) {
        BoardCellDTO *cellDTO = board[i];
        NSString *space = cellDTO.text;
        if (![self isBlank:space] && [self shouldCheckCellDTO:cellDTO]) {
            BoardCellDTO *up = (i - 10) >= 0 ? board[i - 10] : nil;
            BoardCellDTO *left = (i - 1) >= 0 ? board[i - 1] : nil;
            BoardCellDTO *right = (i + 1)%10 > 0 ? board[i + 1] : nil;
            BoardCellDTO *down = (i + 10) < 100 ? board[i + 10] : nil;
            
            if (![self shouldCheckCellDTO:up] && [self shouldCheckCellDTO:down]) {
                BOOL shouldScoreWord = YES;
                int currLetterIndex = i;
                
                BoardCellDTO *currentDTO = cellDTO;
                int scoreForWord = 0;
                while ([self shouldCheckCellDTO:currentDTO] && currLetterIndex < 100) {
                    if (currentDTO.isPending && ![currentDTO.tvc.pid isEqualToString:player]) {
                        if (![self isStartingTile:currentDTO]) {
                            shouldScoreWord = NO;
                        }
                    }
                    if (currentDTO.tvc.isUnsent && [currentDTO.tvc.pid isEqualToString:player]) {
                        scoreForWord += [self getScoreForLetter:currentDTO.text];
                    }
                    currLetterIndex += 10;
                    currentDTO = currLetterIndex < 100 ? board[currLetterIndex] : nil;
                }
                if (shouldScoreWord) {
                    count += scoreForWord * scoreForWord;
                }
            }
            
            if (![self shouldCheckCellDTO:left] && [self shouldCheckCellDTO:right]) {
                BOOL shouldScoreWord = YES;
                int currLetterIndex = i;
                
                BoardCellDTO *currentDTO = cellDTO;
                int scoreForWord = 0;
                while ([self shouldCheckCellDTO:currentDTO] && (currLetterIndex%10 > 0)) {
                    if (currentDTO.isPending && ![currentDTO.tvc.pid isEqualToString:player]) {
                        if (![self isStartingTile:currentDTO]) {
                            shouldScoreWord = NO;
                        }
                    }
                    if (currentDTO.tvc.isUnsent && [currentDTO.tvc.pid isEqualToString:player]) {
                        scoreForWord += [self getScoreForLetter:currentDTO.text];
                    }
                    currLetterIndex++;
                    currentDTO = currLetterIndex%10>0 ? board[currLetterIndex] : nil;
                }
                if (shouldScoreWord) {
                    count += scoreForWord * scoreForWord;
                }
            }
            
        }
    }
    return count * 100;
}

-(NSInteger)getScoreForLetter:(NSString *)letter {
    NSDictionary *scoreDict = @{@"A":[NSNumber numberWithInt:1],
                                @"B":[NSNumber numberWithInt:3],
                                @"C":[NSNumber numberWithInt:3],
                                @"D":[NSNumber numberWithInt:2],
                                @"E":[NSNumber numberWithInt:1],
                                @"F":[NSNumber numberWithInt:4],
                                @"G":[NSNumber numberWithInt:2],
                                @"H":[NSNumber numberWithInt:4],
                                @"I":[NSNumber numberWithInt:1],
                                @"J":[NSNumber numberWithInt:8],
                                @"K":[NSNumber numberWithInt:5],
                                @"L":[NSNumber numberWithInt:1],
                                @"M":[NSNumber numberWithInt:3],
                                @"N":[NSNumber numberWithInt:1],
                                @"O":[NSNumber numberWithInt:1],
                                @"P":[NSNumber numberWithInt:3],
                                @"Q":[NSNumber numberWithInt:10],
                                @"R":[NSNumber numberWithInt:1],
                                @"S":[NSNumber numberWithInt:1],
                                @"T":[NSNumber numberWithInt:1],
                                @"U":[NSNumber numberWithInt:1],
                                @"V":[NSNumber numberWithInt:4],
                                @"W":[NSNumber numberWithInt:4],
                                @"X":[NSNumber numberWithInt:8],
                                @"Y":[NSNumber numberWithInt:4],
                                @"Z":[NSNumber numberWithInt:10]
                                };
    NSNumber *val = [scoreDict valueForKey:letter];
    return [val integerValue];
}

-(BOOL) isStartingTile: (BoardCellDTO *)cell {
    if ([cell.tvc.pid isEqualToString:@"stone"]) {
        return YES;
    }
    return NO;
}

-(BOOL)shouldCheckCellDTO:(BoardCellDTO *)cell {
    NSString *myUserName = [GameConstants getUserName];
    if (!cell) {
        return NO;
    }
    if ([self isBlank: cell.text]) {
        return NO;
    }
    if ([cell.tvc.pid isEqualToString:@"stone"]) {
        return YES;
    }

    if ([cell.tvc.pid isEqualToString:myUserName] || !cell.isPending) {
        return YES;
    }
    
    return NO;
}

-(BOOL)isBlank:(NSString *)space {
    if ([space isEqualToString:@"-"]) {
        return YES;
    }
    return NO;
}

/*
 Note: this method runs synchronous URL requests, so be sure to call it off the main queue
 */
-(BOOL)isValid:(NSString *)word {
    if ([self.scrabbleDict valueForKey:[word lowercaseString]] != nil) {
        return YES;
    }
    return NO;
}

@end
