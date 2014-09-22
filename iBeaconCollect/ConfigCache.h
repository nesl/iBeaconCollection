//
//  ConfigCache.h
//  iBeaconCollect
//
//  Created by Bo Jhang Ho on 9/15/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Utility.h"

@interface ConfigCache : NSObject

- (bool)checkConfigFileExistWithDevId:(NSString*)devId;
- (NSString*)loadConfigFileWithDevId:(NSString*)devId;
- (void)saveConfigFileWithDevId:(NSString*)devId content:(NSString*)content;

@end
