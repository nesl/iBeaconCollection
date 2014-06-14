//
//  LazyFileUploader.h
//  iBeaconMicroBenchmark
//
//  Created by Bo Jhang Ho on 6/10/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Utility.h"

@interface LazyFileUploader : NSObject

+ (void)upload:(NSString*)filename webIdentifier:(NSString*)webid callback:(void (^)(BOOL result))callback;

@end
