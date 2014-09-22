//
//  ConfigCache.m
//  iBeaconCollect
//
//  Created by Bo Jhang Ho on 9/15/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import "ConfigCache.h"

@implementation ConfigCache

- (bool)checkConfigFileExistWithDevId:(NSString*)devId {
    NSString *filename = [[NSString alloc] initWithFormat:@"config%@", devId];
    return iosfileExist([filename UTF8String]);
}

- (NSString*)loadConfigFileWithDevId:(NSString*)devId {
    NSString *filename = [[NSString alloc] initWithFormat:@"config%@", devId];
    return [[NSString alloc] initWithContentsOfFile:getPathName([filename UTF8String]) encoding:NSUTF8StringEncoding error:nil];
}

- (void)saveConfigFileWithDevId:(NSString*)devId content:(NSString*)content {
    NSString *filename = [[NSString alloc] initWithFormat:@"config%@", devId];
    NSError *error;
    [content writeToFile:getPathName([filename UTF8String]) atomically:YES encoding:NSUTF8StringEncoding error:&error];
}


@end
