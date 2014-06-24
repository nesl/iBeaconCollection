//
//  InfoRestoreHandler.m
//  iBeaconCollect
//
//  Created by Bo Jhang Ho on 6/23/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import "InfoRestoreHandler.h"


@implementation InfoRestoreHandler

+ (NSString*)getIPPort {
    FILE *f = iosfopen("pp", "r");
    if (f == NULL) {
        f = iosfopen("pp", "w");
        fprintf(f, "18.111.3.140:8888");
        fclose(f);
        f = iosfopen("pp", "r");
    }
    char tmp[1000];
    fscanf(f, "%s", tmp);
    fclose(f);
    return [[NSString alloc] initWithFormat:@"%s", tmp];
}

+ (BOOL)checkIPPort:(NSString*)ipport {
    //************************* ^([0-9])+\.([0-9])+\.([0-9])+\.([0-9])+(\:[0-9]+)?$
    
    /*NSRange   searchedRange = NSMakeRange(0, [searchedString length]);
    NSString *pattern = @"([0-9]*)\\.([0-9]*)\\.([0-9]*)\\.([0-9]*)(:{2,63}(?<!-))\\.?((?:[a-zA-Z0-9]{2,})?(?:\\.[a-zA-Z0-9]{2,})?)";
    NSError  *error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern" options:0 error:&error];
                                  NSArray* matches = [regex matchesInString:searchedString options:0 range: searchedRange];
                                  for (NSTextCheckingResult* match in matches) {
                                      NSString* matchText = [searchedString substringWithRange:[match range]];
                                      NSLog(@"match: %@", matchText);
                                      NSRange group1 = [match rangeAtIndex:1];
                                      NSRange group2 = [match rangeAtIndex:2];
                                      NSLog(@"group1: %@", [searchedString substringWithRange:group1]);
                                      NSLog(@"group2: %@", [searchedString substringWithRange:group2]);
                                  }
     */
    return true;
}

+ (void)commitIPPort:(NSString*)ipport {
    FILE *f = iosfopen("pp", "w");
    fprintf(f, "%s", [ipport UTF8String]);
    fclose(f);
}

@end
