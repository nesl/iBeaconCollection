//
//  LazyFileUploader.m
//  iBeaconMicroBenchmark
//
//  Created by Bo Jhang Ho on 6/10/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import "LazyFileUploader.h"

@implementation LazyFileUploader

+ (void)upload:(NSString*)filename webIdentifier:(NSString*)webid callback:(void (^)(BOOL result))callback {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL success = false;
        int trial = 2;
        if (iosfileExist([filename UTF8String])) {
            while (success == false && trial > 0) {
                trial--;
                NSString *urlString = @"http://172.17.5.61/iosupload/index.php";
                NSMutableURLRequest *request= [[NSMutableURLRequest alloc] init];
                [request setURL:[NSURL URLWithString:urlString]];
                [request setHTTPMethod:@"POST"];
                NSString *boundary = @"---------------------------14737809831466499882746641449";
                NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
                [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
                
                NSMutableData *postbody = [NSMutableData data];
                [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n" ,boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", webid, filename] dataUsingEncoding:NSUTF8StringEncoding]];
                [postbody appendData:[@"Content-Type: text/plain\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                
                NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:getPathName([filename UTF8String])];
                [postbody appendData:fileData];
                
                [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [request setHTTPBody:postbody];
                
                
                
                NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                if (returnData != nil) {
                    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
                    NSLog(@"%@", returnString);
                    if ([returnString isEqualToString:@"okdes\n\n"]) {
                        success = true;
                    }
                }
            }
        }
        callback(success);
    });
}

@end
