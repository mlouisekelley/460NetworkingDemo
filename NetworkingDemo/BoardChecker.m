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

@end

@implementation BoardChecker


/*
 Note: this method runs synchronous URL requests, so be sure to call it off the main queue
 This checks the board for incorrect words. If the board is valid, the returned array
 will be empty.
 */
+(NSArray *)checkBoardState:(NSArray *)board {
    
    NSMutableArray *incorrectWords = [[NSMutableArray alloc] init];
    for (int i = 0; i<[board count]; i++) {
        BoardCellDTO *cellDTO = board[i];
        NSString *space = cellDTO.text;
        if (![self isBlank:space] && [self shouldCheckCellDTO:cellDTO]) {
            NSString *up = (i - 10) >= 0 ? ((BoardCellDTO *)board[i - 10]).text : @"-";
            NSString *left = (i - 1) >= 0 ? ((BoardCellDTO *)board[i - 1]).text : @"-";
            NSString *right = (i + 1)%10 > 0 ? ((BoardCellDTO *)board[i + 1]).text : @"-";
            NSString *down = (i + 10) < 100 ? ((BoardCellDTO *)board[i + 10]).text : @"-";
            
            if ([self isBlank:up] && ![self isBlank:down]) {
                NSString *word = space;
                int currLetterIndex = i + 10;
                BoardCellDTO *currentDTO = board[currLetterIndex];
                while (![self isBlank:currentDTO.text] && currLetterIndex < 100) {
                    word = [word stringByAppendingString:currentDTO.text];
                    currLetterIndex += 10;
                    currentDTO = board[currLetterIndex];
                }
                if (![self isValid:word]) {
                    [incorrectWords addObject:word];
                }
            }
            
            if ([self isBlank:left] && ![self isBlank:right]) {
                NSString *word = space;
                int currLetterIndex = i + 1;
                BoardCellDTO *currentDTO = board[currLetterIndex];
                while (![self isBlank:currentDTO.text] && (currLetterIndex%10 > 0)) {
                    word = [word stringByAppendingString:currentDTO.text];
                    currLetterIndex++;
                    currentDTO = board[currLetterIndex];
                }
                if (![self isValid:word]) {
                    [incorrectWords addObject:word];
                }
            }
            
        }
    }
    return incorrectWords;
}

+(BOOL)shouldCheckCellDTO:(BoardCellDTO *)cell {
    //refactor to include dynamic player numbers
    if (cell.player != 0 && cell.pending != 1) {
        return YES;
    }
    if (cell.player == 0) {
        return YES;
    }
    
    return NO;
}

+(BOOL)isBlank:(NSString *)space {
    if ([space isEqualToString:@"-"]) {
        return YES;
    }
    return NO;
}

/*
 Note: this method runs synchronous URL requests, so be sure to call it off the main queue
 */
+(BOOL)isValid:(NSString *)word {
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
        NSString *entryString = @"<entry id=";
        if (![responseString containsString:entryString]) {
            return NO;
        }
    }
    else {
        NSLog(@"%@", [error localizedDescription]);
    }
    return YES;
}

@end
