//
//  BoardChecker.m
//  NetworkingDemo
//
//  Created by Margaret Kelley on 1/14/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//

#import "BoardChecker.h"
#import "GameConstants.h"

@interface BoardChecker()

@end

@implementation BoardChecker


/*
 Note: this method runs synchronous URL requests, so be sure to call it off the main queue
 */
+(BOOL)checkBoardState:(NSArray *)board {
    
    for (int i = 0; i<[board count]; i++) {
        NSString *space = board[i];
        if (![self isBlank:space]) {
            NSString *up = (i - 10) >= 0 ? board[i - 10] : @"-";
            NSString *left = (i - 1) >= 0 ? board[i - 1] : @"-";
            NSString *right = (i + 1)%10 > 0 ? board[i + 1] : @"-";
            NSString *down = (i + 10) < 100 ? board[i + 10] : @"-";
            
            if ([self isBlank:up] && ![self isBlank:down]) {
                NSString *word = space;
                int currLetterIndex = i + 10;
                while (![self isBlank:board[currLetterIndex]] && currLetterIndex < 100) {
                    word = [word stringByAppendingString:board[currLetterIndex]];
                    currLetterIndex += 10;
                }
                NSLog(@"%@", word);
                if (![self isValid:word]) {
                    NSLog(@"NOT A VALID WORD FOUND");
                    return NO;
                }
            }
            
            if ([self isBlank:left] && ![self isBlank:right]) {
                NSString *word = space;
                int currLetterIndex = i + 1;
                while (![self isBlank:board[currLetterIndex]] && (currLetterIndex%10 > 0)) {
                    word = [word stringByAppendingString:board[currLetterIndex]];
                    currLetterIndex++;
                }
                NSLog(@"%@", word);
                if (![self isValid:word]) {
                    NSLog(@"NOT A VALID WORD FOUND");
                    return NO;
                }
            }
            
        }
    }
    NSLog(@"BOARD IS VALID!!!");
    return YES;
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
