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

@end

@implementation BoardChecker


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
    for (int i = 0; i<[board count]; i++) {
        BoardCellDTO *cellDTO = board[i];
        NSString *space = cellDTO.text;
        if (![self isBlank:space] && [self shouldCheckCellDTO:cellDTO]) {
            BoardCellDTO *up = (i - 10) >= 0 ? board[i - 10] : nil;
            BoardCellDTO *left = (i - 1) >= 0 ? board[i - 1] : nil;
            BoardCellDTO *right = (i + 1)%10 > 0 ? board[i + 1] : nil;
            BoardCellDTO *down = (i + 10) < 100 ? board[i + 10] : nil;
            
            if (![self shouldCheckCellDTO:up] && [self shouldCheckCellDTO:down]) {
                NSString *word = space;
                int currLetterIndex = i + 10;
                BoardCellDTO *currentDTO = board[currLetterIndex];
                while ([self shouldCheckCellDTO:currentDTO] && currLetterIndex < 100) {
                    word = [word stringByAppendingString:currentDTO.text];
                    currLetterIndex += 10;
                    currentDTO = currLetterIndex < 100 ? board[currLetterIndex] : nil;
                }
                if (![self isValid:word]) {
                    [incorrectWords addObject:word];
                }
            }
            
            if (![self shouldCheckCellDTO:left] && [self shouldCheckCellDTO:right]) {
                NSString *word = space;
                int currLetterIndex = i + 1;
                BoardCellDTO *currentDTO = board[currLetterIndex];
                while ([self shouldCheckCellDTO:currentDTO] && (currLetterIndex%10 > 0)) {
                    word = [word stringByAppendingString:currentDTO.text];
                    currLetterIndex++;
                    currentDTO = currLetterIndex%10>0 ? board[currLetterIndex] : nil;
                }
                if (![self isValid:word]) {
                    [incorrectWords addObject:word];
                }
            }
            
        }
    }
    return incorrectWords;
}

-(NSUInteger)calculateScoreForBoard:(NSArray *)board {
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
                NSString *word = space;
                BOOL shouldScoreWord = (cellDTO.pending == 1) ? YES : NO;
                int currLetterIndex = i + 10;
                BoardCellDTO *currentDTO = board[currLetterIndex];
                while ([self shouldCheckCellDTO:currentDTO] && currLetterIndex < 100) {
                    word = [word stringByAppendingString:currentDTO.text];
                    if (currentDTO.pending == 1) {
                        shouldScoreWord = YES;
                    }
                    currLetterIndex += 10;
                    currentDTO = currLetterIndex < 100 ? board[currLetterIndex] : nil;
                }
                if (shouldScoreWord) {
                    count += [word length] * [word length];
                }
            }
            
            if (![self shouldCheckCellDTO:left] && [self shouldCheckCellDTO:right]) {
                NSString *word = space;
                BOOL shouldScoreWord = (cellDTO.pending == 1) ? YES : NO;
                int currLetterIndex = i + 1;
                BoardCellDTO *currentDTO = board[currLetterIndex];
                while ([self shouldCheckCellDTO:currentDTO] && (currLetterIndex%10 > 0)) {
                    word = [word stringByAppendingString:currentDTO.text];
                    if (currentDTO.pending == 1) {
                        shouldScoreWord = YES;
                    }
                    currLetterIndex++;
                    currentDTO = currLetterIndex%10>0 ? board[currLetterIndex] : nil;
                }
                if (shouldScoreWord) {
                    count += [word length] * [word length];
                }
            }
            
        }
    }
    return count;
}

-(BOOL)shouldCheckCellDTO:(BoardCellDTO *)cell {
    NSString *myUserName = [GameConstants getUserName];
    if (!cell) {
        return NO;
    }
    if ([self isBlank: cell.text]) {
        return NO;
    }
    if (![cell.playerUserName isEqualToString:myUserName] && cell.pending != 1) {
        return YES;
    }
    if ([cell.playerUserName isEqualToString:myUserName]) {
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
    //first check if the word is already in the alreadyCheckedWords dictionary
    NSNumber *value =[self.alreadyCheckedWords objectForKey:word];
    if (value != nil) {
        return [value boolValue];
    }
    
    //if no word was found, check dictionary
    NSString *query = [NSString stringWithFormat:@"http://www.dictionaryapi.com/api/v1/references/collegiate/xml/%@?key=%@", word, DICTIONARY_KEY];
    NSURL *url = [NSURL URLWithString:query];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLResponse *response;
    NSError *error;
    //send it synchronous
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    // check for an error. If there is a network error, you should handle it here.
    if(!error)
    {
        //log response
        //NSLog(@"Response from server = %@", responseString);
        NSString *entryString = [NSString stringWithUTF8String:"<entry id="];
        NSRange range = [responseString rangeOfString:entryString];
        if (range.length == 0) {
            [self.alreadyCheckedWords setValue:[NSNumber numberWithBool:NO] forKey:word];
            return NO;
        }
    }
    else {
        NSLog(@"%@", [error localizedDescription]);
    }
    [self.alreadyCheckedWords setValue:[NSNumber numberWithBool:YES] forKey:word];
    return YES;
}

@end
