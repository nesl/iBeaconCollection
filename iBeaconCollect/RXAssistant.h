//
//  RXAssistant.h
//  iBeaconCollect
//
//  Created by Bo Jhang Ho on 9/12/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

#import "IBeaconIdentifier.h"
#import "IBeaconStatistics.h"
//#import "MainViewController.h"

@class MainViewController;


@interface RXAssistant : NSObject

- (id)initWithViewController:(MainViewController*)_controller;
- (void)panelAlpha:(double)alpha;
- (void)updateIBeacons:(NSArray*)beacons;
- (void)disableRx;
- (void)enableRx;
- (void)notifyRangingEventBeaconId:(IBeaconIdentifier*)recvId rssi:(int)rssi accuracy:(double)acc distance:(CLProximity)dis;
- (void)notifyMonitoringEventIdentifier:(NSString*)identifier isInEvent:(bool)isIn;
- (void)notifyWillDetermineState;
- (void)notifyDetermineStateEventIdentifier:(NSString*)identifier state:(CLRegionState)state;
- (void)isNotifiedToFlipPage;
- (void)isNotifiedStartFlagManuallyFlip:(bool)manuallyFlip;

@end
