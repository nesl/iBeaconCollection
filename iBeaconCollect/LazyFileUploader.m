//
//  LazyFileUploader.m
//  iBeaconMicroBenchmark
//
//  Created by Bo Jhang Ho on 6/10/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import "LazyFileUploader.h"

@implementation LazyFileUploader

+ (void)uploadFile:(NSString*)filename urlString:(NSString*)urlString formFilename:(NSString*)formFilename callback:(void (^)(BOOL result))callback {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL success = false;
        int trial = 2;
        if (iosfileExist([filename UTF8String])) {
            while (success == false && trial > 0) {
                trial--;
                NSMutableURLRequest *request= [[NSMutableURLRequest alloc] init];
                [request setURL:[NSURL URLWithString:urlString]];
                [request setHTTPMethod:@"POST"];
                NSMutableData *postbody = [NSMutableData data];
                NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:getPathName([filename UTF8String])];
                [postbody appendData:fileData];
                [request setHTTPBody:postbody];
                
                
                
                NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                if (returnData != nil) {
                    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
                    NSLog(@"%@", returnString);
                    if ([returnString isEqualToString:@"okdes"]) {
                        success = true;
                    }
                }
            }
        }
        callback(success);
    });
}

@end
