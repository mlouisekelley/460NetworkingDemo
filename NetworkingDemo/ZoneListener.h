//
//  ZoneListener.h
//  WordPlay
//
//  Created by Kyle Bailey on 4/5/15.
//  Copyright (c) 2015 Margaret Kelley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppWarp_iOS_SDK/AppWarp_iOS_SDK.h>
#import "ViewController.h"

@interface ZoneListener : NSObject <ZoneRequestListener>

@property (nonatomic,retain)id helper;


-(id)initWithHelper:(id)l_helper;



@end
