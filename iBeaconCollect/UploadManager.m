//
//  UploadManager.m
//  iBeaconCollect
//
//  Created by Bo Jhang Ho on 6/16/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import "UploadManager.h"

NSString *uploadManagerIpPortPrefix;
void (^uploadManagerWillStartBlock)(int nrToUpload) = nil;
void (^uploadManagerDidUploadBlock)(int nrFinished, int total, bool isAutoMode) = nil;
void (^uploadManagerUploadFailed)(int nrFinished, int total, bool isAutoMode) = nil;
void (^uploadManagerUploadAllSucceeded)(int total, bool isAutoMode) = nil;
void (^uploadManagerNothingToUploadBlock)() = nil;

NSTimer *uploadManagerTimerAutoUpload;
int uploadManagerUploadProgress;
int uploadManagerUploadTotal;
BOOL uploadManagerIsAutoUpload;

@implementation UploadManager

+ (void)globalInitWithIpPortPrefix:(NSString*)prefix {
    uploadManagerIpPortPrefix = prefix;
}

+ (void)addUploadWillStartBlock:(void (^)(int nrToUpload))callback {
    uploadManagerWillStartBlock = callback;
}

+ (void)addDidUploadBlock:(void (^)(int nrFinished, int total, bool isAutoMode))callback {
    uploadManagerDidUploadBlock = callback;
}

+ (void)addUploadFailedBlock:(void (^)(int nrFinished, int total, bool isAutoMode))callback {
    uploadManagerUploadFailed = callback;
}

+ (void)addUploadAllSucceededBlock:(void (^)(int total, bool isAutoMode))callback {
    uploadManagerUploadAllSucceeded = callback;
}

+ (void)addNothingToUploadBlock:(void (^)())callback {
    uploadManagerNothingToUploadBlock = callback;
}

+ (void)setUploadModeAutomatically:(BOOL)option {
    if (option == YES) {
        uploadManagerTimerAutoUpload = [NSTimer scheduledTimerWithTimeInterval:300
                                                                        target:self
                                                                      selector:@selector(uploadData:)
                                                                      userInfo:nil
                                                                       repeats:YES];
    }
    else {
        [uploadManagerTimerAutoUpload invalidate];
    }
}

+ (void)uploadNow {
    [UploadManager uploadData:nil];
}

+ (void)uploadData:(NSTimer*)timer {
    uploadManagerUploadTotal = [DataLogger queryNumberToUpload];
    uploadManagerUploadProgress = -1;
    uploadManagerIsAutoUpload = (timer != nil);
    if (uploadManagerUploadTotal == 0) {
        NSLog(@"nothing to upload, with mode: %d", uploadManagerIsAutoUpload);
        if (uploadManagerIsAutoUpload == false)
            uploadManagerNothingToUploadBlock();
    }
    else {
        uploadManagerWillStartBlock(uploadManagerUploadTotal);
        uploadManagerHandleUploadResultBlock(true);
    }
}

void (^uploadManagerHandleUploadResultBlock)(BOOL) = ^(BOOL result) {
    if (result == false)
        uploadManagerUploadFailed(uploadManagerUploadProgress, uploadManagerUploadTotal, uploadManagerIsAutoUpload);
    else {
        uploadManagerUploadProgress++;
        if (uploadManagerUploadProgress > 0)
            [DataLogger commit];
        if (uploadManagerUploadProgress == uploadManagerUploadTotal) {
            uploadManagerUploadAllSucceeded(uploadManagerUploadTotal, uploadManagerIsAutoUpload);
        }
        else {
            uploadManagerDidUploadBlock(uploadManagerUploadProgress, uploadManagerUploadTotal, uploadManagerIsAutoUpload);
            NSString *fileName = [DataLogger fetchNext];
            NSString *url = [[NSString alloc] initWithFormat:@"%@%@", uploadManagerIpPortPrefix, fileName];
            NSLog(@"trying to upload %@", url);
            [LazyFileUploader uploadFile:fileName urlString:url callback:uploadManagerHandleUploadResultBlock];
        }
    }
};

@end
