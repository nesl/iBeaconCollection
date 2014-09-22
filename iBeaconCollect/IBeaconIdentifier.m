//
//  IBeaconIdentifier.m
//  iBeaconCollect
//
//  Created by Bo Jhang Ho on 9/8/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//


#import "IBeaconIdentifier.h"

@implementation IBeaconIdentifier {
    CLBeaconRegion *regionCache;
}
    
@synthesize uuid;
@synthesize major;
@synthesize minor;

- (bool)isEqual:(IBeaconIdentifier*)rhs{
    return [uuid isEqual:rhs.uuid] && major == rhs.major && minor == rhs.minor;
}

- (bool)asARuleToApplyIBeacon:(IBeaconIdentifier*)beacon {
    return [uuid isEqual:beacon.uuid]
        && (major == -1 || major == beacon.major)
        && (minor == -1 || minor == beacon.minor);
}

- (NSString*)getIdentifierName {
    return [[NSString alloc] initWithFormat:@"%@-%d-%d", uuid.UUIDString, major, minor];
}

- (CLBeaconRegion*)getRegion {
    if (regionCache == nil) {
        if (major == -1 && minor == -1)
            regionCache = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[self getIdentifierName]];
        else if (major == -1)
            regionCache = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major identifier:[self getIdentifierName]];
        else
            regionCache = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major minor:minor identifier:[self getIdentifierName]];
        regionCache.notifyEntryStateOnDisplay = YES;
        regionCache.notifyOnEntry = YES;
        regionCache.notifyOnExit = YES;
    }
    return regionCache;
}

- (NSString*)getMajorString {
    return [self convertToStringMajorOrMinor:major];
}

- (NSString*)getMinorString {
    return [self convertToStringMajorOrMinor:minor];
}

#pragma mark -

- (NSString*)convertToStringMajorOrMinor:(int)mm {
    if (mm == -1)
        return @"*";
    else
        return [[NSString alloc] initWithFormat:@"%d", mm];
}

@end
