//
//  IBeaconIdentifier.h
//  iBeaconCollect
//
//  Created by Bo Jhang Ho on 9/8/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

/*
 * treat this class as a data structure. it didn't validate the correctness of all attributes.
 */

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@interface IBeaconIdentifier : NSObject

@property NSUUID *uuid;
@property int major;
@property int minor;

- (bool)isEqual:(IBeaconIdentifier*)rhs;
- (bool)asARuleToApplyIBeacon:(IBeaconIdentifier*)beacon;
- (NSString*)getIdentifierName;
- (CLBeaconRegion*)getRegion;
- (NSString*)getMajorString;
- (NSString*)getMinorString;

@end
