//
//  InfoRestoreHandler.h
//  iBeaconCollect
//
//  Created by Bo Jhang Ho on 6/23/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Utility.h"

@interface InfoRestoreHandler : NSObject

+ (NSString*)getIPPort;
+ (void)commitIPPort:(NSString*)ipport;

@end
