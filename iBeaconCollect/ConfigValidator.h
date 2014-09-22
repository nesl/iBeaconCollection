//
//  ConfigValidator.h
//  iBeaconCollect
//
//  Created by Bo Jhang Ho on 9/8/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "MainViewController.h"
#import "IBeaconIdentifier.h"
#import "RXAssistant.h"

@class MainViewController;

@interface ConfigValidator : NSObject

- (id)initWithViewController:(MainViewController*)controller beaconDataReportTo:(RXAssistant*)rxAssistant andDeviceId:(NSString*)devId;
- (NSString*)validateConfigContent:(NSString*)content;

@end


