//
//  Utility.m
//  CollectSensorData
//
//  Created by Bo Jhang Ho on 3/9/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import "Utility.h"

@implementation Utility

+ (double)getRandomNumberMin:(double)min max:(double)max {
    return ((double)arc4random() / 0x100000000) * (max - min) + min;
}

+ (NSString*)humanReadableTimeDuration:(double)sec {
    int s = (int)sec;
    int m = s / 60;
    int h = m / 60;
    int d = h / 24;
    s %= 60;
    m %= 60;
    h %= 24;
    if (d > 0)
        return [[NSString alloc] initWithFormat:@"%dd%02dh%02dm%02ds", d, h, m, s];
    else if (h > 0)
        return [[NSString alloc] initWithFormat:@"%dh%02dm%02ds", h, m, s];
    else if (m > 0)
        return [[NSString alloc] initWithFormat:@"%dm%02ds", m, s];
    return [[NSString alloc] initWithFormat:@"%ds", s];
}

NSString *getPathName(const char *filename) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileString = [NSString stringWithCString:filename encoding:NSASCIIStringEncoding];
    return [documentsDirectory stringByAppendingPathComponent:fileString];
}

FILE *iosfopen(const char *filename, const char *mode) {
    const char *filePath = [getPathName(filename) cStringUsingEncoding:NSASCIIStringEncoding];
    return fopen(filePath, mode);
}

NSInteger iosfileSize(const char *filename) {
    NSString *path = getPathName(filename);
    NSError *attributesError = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&attributesError];
    return [fileAttributes fileSize];
}

bool iosfileExist(const char *fileName) {
    FILE *f = iosfopen(fileName, "r");
    if (f == NULL)
        return false;
    fclose(f);
    return true;
}

bool iosfileDelete(const char *filename) {
    NSString *path = getPathName(filename);
    return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

@end
