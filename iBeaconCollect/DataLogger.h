//
//  DataLogger.h
//  iBeaconCollect
//
//  Created by Bo Jhang Ho on 6/16/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Utility.h"

@interface DataLogger : NSObject

+ (void)globalInit:(NSString*)deviceID;
+ (int)queryNumberToUpload;
+ (NSString*)fetchNext;
+ (BOOL)commit;
+ (void)putLine:(NSString*)line;

@end

