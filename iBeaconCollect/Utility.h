//
//  Utility.h
//  CollectSensorData
//
//  Created by Bo Jhang Ho on 3/9/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject

+ (double)getRandomNumberMin:(double)min max:(double)max;
+ (NSString*)humanReadableTimeDuration:(double)sec;
NSString *getPathName(const char *filename);
FILE *iosfopen(const char *filename, const char *mode);
NSInteger iosfileSize(const char *filename);
bool iosfileExist(const char *fileName);
bool iosfileDelete(const char *fileName);

@end
