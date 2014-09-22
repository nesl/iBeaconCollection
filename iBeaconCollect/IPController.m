//
//  IPController.m
//  iBeaconCollect
//
//  Created by Bo Jhang Ho on 9/7/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import "IPController.h"

@implementation IPController {
    NSMutableArray *ips;
}


+ (IPController*)getInstance {
    static IPController *re = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        re = [[self alloc] init];
    });
    return re;
}

- (id)init {
    FILE *f = iosfopen("pp", "r");
    if (f == NULL) {
        f = iosfopen("pp", "w");
        fprintf(f, "http://18.111.3.140:8888");
        fclose(f);
        f = iosfopen("pp", "r");
    }
    
    ips = [[NSMutableArray alloc] init];
    char tmp[1000];
    int count = 0;
    while (count < 6 && fscanf(f, "%s", tmp) == 1) {
        [ips addObject:[[NSString alloc] initWithFormat:@"%s", tmp]];
        count++;
    }
    fclose(f);
    return self;
    //return [[NSString alloc] initWithFormat:@"%s", tmp];
}

- (NSString*)firstIPPort {
    return ips[0];
}

- (NSArray*)allIPPorts {
    return [NSArray arrayWithArray:ips];
}

- (void)commitIPPort:(NSString*)ipport {
    [ips removeObject:ipport];
    if (ips.count == 6)
        [ips removeLastObject];
    [ips insertObject:ipport atIndex:0];
    FILE *f = iosfopen("pp", "w");
    for (NSString *n in ips)
        fprintf(f, "%s\n", [n UTF8String]);
    fclose(f);
}

- (bool)hasRecents {
    return ips.count > 1;
}

@end
