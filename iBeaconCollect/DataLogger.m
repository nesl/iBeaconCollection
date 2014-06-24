//
//  DataLogger.m
//  iBeaconCollect
//
//  Created by Bo Jhang Ho on 6/16/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import "DataLogger.h"

NSDateFormatter *dataLoggerDateFormatterFileName;
int dataLoggerNoNextCommit;
NSString *dataLoggerDeviceID;
FILE *dataLoggerFLog;
NSString *dataLoggerFileNameIndex;
NSString *dataLoggerFileNameCommit;
NSMutableArray *dataLoggerFileNameLogs;
NSObject *dataLoggerLock;
NSTimer *timerCutFile;

@implementation DataLogger


+ (void)globalInit:(NSString*)deviceID {
    dataLoggerDeviceID = deviceID;
    dataLoggerDateFormatterFileName = [[NSDateFormatter alloc] init];
    [dataLoggerDateFormatterFileName setDateFormat:@"yyyyMMddHHmmss"];
    dataLoggerFileNameIndex = [[NSString alloc] initWithFormat:@"index_%@", deviceID];
    dataLoggerFileNameCommit = [[NSString alloc] initWithFormat:@"commit_%@", deviceID];
    FILE *findex;
    FILE *fcommit;
    fcommit = iosfopen([dataLoggerFileNameCommit UTF8String], "r");
    if (fcommit == NULL) {
        fcommit = iosfopen([dataLoggerFileNameCommit UTF8String], "w");
        fprintf(fcommit, "0");
        fclose(fcommit);
        findex = iosfopen([dataLoggerFileNameIndex UTF8String], "w");
        fclose(findex);
        fcommit = iosfopen([dataLoggerFileNameCommit UTF8String], "r");
    }
    fscanf(fcommit, "%d", &dataLoggerNoNextCommit);
    findex = iosfopen([dataLoggerFileNameIndex UTF8String], "r");
    dataLoggerFileNameLogs = [[NSMutableArray alloc] init];
    char tmp[1000];
    while (fgets(tmp, 1000, findex) != NULL) {
        [dataLoggerFileNameLogs addObject:[[[NSString alloc] initWithFormat:@"%s", tmp] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
    for (NSString *s in dataLoggerFileNameLogs)
        NSLog(@"find file %@", s);
    fclose(findex);
    dataLoggerFLog = [DataLogger newFile];
    dataLoggerLock = [[NSObject alloc] init];
    timerCutFile = [NSTimer scheduledTimerWithTimeInterval:300
                                                    target:self
                                                  selector:@selector(cut:)
                                                  userInfo:nil
                                                   repeats:YES];
}

+ (int)queryNumberToUpload {
    @synchronized (dataLoggerLock) {
        int d = (int)[dataLoggerFileNameLogs count] - dataLoggerNoNextCommit - 1;
        NSLog(@"cur=%d  total=%d", dataLoggerNoNextCommit, (int)[dataLoggerFileNameLogs count]);
        if (d <= 0)
            return 0;
        else
            return d;
    }
}

+ (NSString*)fetchNext {
    @synchronized (dataLoggerLock) {
        if ([dataLoggerFileNameLogs count] - dataLoggerNoNextCommit <= 1)
            return nil;
        else
            return dataLoggerFileNameLogs[dataLoggerNoNextCommit];
    }
}

+ (BOOL)commit {
    @synchronized (dataLoggerLock) {
        if ([dataLoggerFileNameLogs count] - dataLoggerNoNextCommit <= 1)
            return NO;
        else {
            dataLoggerNoNextCommit++;
            FILE *fcommit = iosfopen([dataLoggerFileNameCommit UTF8String], "w");
            fprintf(fcommit, "%d", dataLoggerNoNextCommit);
            fclose(fcommit);
            return YES;
        }
    }
}

+ (void)putLine:(NSString*)line {
    @synchronized (dataLoggerLock) {
        if (dataLoggerFLog != NULL) {
            fprintf(dataLoggerFLog, "%s\n", [line UTF8String]);
            fflush(dataLoggerFLog);
        }
    }
}

+ (FILE*)newFile {
    NSString *newFileName = [[NSString alloc] initWithFormat:@"%@_%@",dataLoggerDeviceID, [dataLoggerDateFormatterFileName stringFromDate:[NSDate date]]];
    NSLog(@"DataLogger create new file %@", newFileName);
    [dataLoggerFileNameLogs addObject:newFileName];
    FILE *findex = iosfopen([dataLoggerFileNameIndex UTF8String], "a");
    fprintf(findex, "%s\n", [newFileName UTF8String]);
    fclose(findex);
    return iosfopen([newFileName UTF8String], "w");
}

+ (void)cut:(NSTimer*)timer {
    @synchronized (dataLoggerLock) {
        fclose(dataLoggerFLog);
        dataLoggerFLog = [DataLogger newFile];
    }
}


@end
