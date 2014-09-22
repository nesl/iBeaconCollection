//
//  IPController.h
//  iBeaconCollect
//
//  Created by Bo Jhang Ho on 9/7/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Utility.h"

@interface IPController : NSObject

+ (IPController*)getInstance;
- (NSString*)firstIPPort;
- (NSArray*)allIPPorts;
- (void)commitIPPort:(NSString*)ipport;
- (bool)hasRecents;

@end
