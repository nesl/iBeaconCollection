//
//  IBeaconStatistics.h
//  iBeaconCollect
//
//  Created by Bo Jhang Ho on 9/12/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@interface IBeaconStatistics : NSObject

- (id)init;

@property int nrIn;
@property int nrOut;
@property int nrCnt;
@property NSString *inOutStatus;
@property bool inOutStatusError;
@property CLRegionState regionStat;
@property int lastRssi;
@property double lastAccuracy;
@property CLProximity lastDistance;

- (NSString*)getLastRssiString;
- (NSString*)getLastDisString;

@end
