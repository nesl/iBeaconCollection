//
//  UploadManager.h
//  iBeaconCollect
//
//  Created by Bo Jhang Ho on 6/16/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DataLogger.h"
#import "LazyFileUploader.h"

@interface UploadManager : NSObject

+ (void)globalInitWithIpPortPrefix:(NSString*)prefix;
+ (void)addUploadWillStartBlock:(void (^)(int nrToUpload))callback;
+ (void)addDidUploadBlock:(void (^)(int nrFinished, int total, bool isAutoMode))callback;
+ (void)addUploadFailedBlock:(void (^)(int nrFinished, int total, bool isAutoMode))callback;
+ (void)addUploadAllSucceededBlock:(void (^)(int total, bool isAutoMode))callback;
+ (void)addNothingToUploadBlock:(void (^)())callback;
+ (void)setUploadModeAutomatically:(BOOL)option;
+ (void)uploadNow;

@end
