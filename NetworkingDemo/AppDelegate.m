//
//  AppDelegate.m
//  NetworkingDemo
//
//  Created by Margaret Kelley on 12/25/14.
//  Copyright (c) 2014 Margaret Kelley. All rights reserved.
//

#import "AppDelegate.h"
#import "RoomListener.h"
#import "NotificationListener.h"
#import "ConnectionListener.h"
#import <AppWarp_iOS_SDK/AppWarp_iOS_SDK.h>
#import <Parse/Parse.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // [Optional] Power your app with Local Datastore. For more info, go to
    // https://parse.com/docs/ios_guide#localdatastore/iOS
    [Parse enableLocalDatastore];
    
    // Initialize Parse.
    [Parse setApplicationId:@"csVfSoNm6NRcJo1oTX5msY9YfXSttMVoLKybBjyk"
                  clientKey:@"ntlK83NUwHAcYcwVCRBOmuV4MEafaoYbh6NnIWaH"];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    //start a background sound
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"background_music" ofType: @"mp3"];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath ];
    self.myAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    self.myAudioPlayer.numberOfLoops = -1; //infinite loop
    [self.myAudioPlayer play];
    
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[WarpClient getInstance] disconnect];
}

@end
