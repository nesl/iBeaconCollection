//
//  IBeaconStatistics.m
//  iBeaconCollect
//
//  Created by Bo Jhang Ho on 9/12/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import "IBeaconStatistics.h"

@implementation IBeaconStatistics

@synthesize nrIn;
@synthesize nrOut;
@synthesize nrCnt;
@synthesize inOutStatus;
@synthesize inOutStatusError;
@synthesize regionStat;
@synthesize lastRssi;
@synthesize lastAccuracy;
@synthesize lastDistance;

- (id)init {
    id re = [super init];
    nrIn = 0;
    nrOut = 0;
    nrCnt = 0;
    inOutStatus = @"--";
    inOutStatusError = false;
    regionStat = CLRegionStateUnknown;
    lastRssi = -1;
    lastAccuracy = -1;
    return re;
}

- (NSString*)getLastRssiString {
    if (nrCnt == 0)
        return @"--";
    else if (lastRssi >= -1)
        return @"x";
    else
        return [[NSString alloc] initWithFormat:@"%d", lastRssi];
}

- (NSString*)getLastDisString {
    if (nrCnt == 0)
        return @"--";
    else if (lastAccuracy <= 0.0)
        return @"x";
    else {
        NSString *disTok = @"?";
        switch (lastDistance) {
            case CLProximityImmediate:  disTok = @"Im";  break;
            case CLProximityNear:       disTok = @"N";   break;
            case CLProximityFar:        disTok = @"F";   break;
            default:  break;
        }
        return [[NSString alloc] initWithFormat:@"%@-%.2lf", disTok, lastAccuracy];
    }
}

@end
