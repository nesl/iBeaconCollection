//
//  ConfigValidator.m
//  iBeaconCollect
//
//  Created by Bo Jhang Ho on 9/8/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import "ConfigValidator.h"

#import "MainViewController.h"

const int ERROR_CODE = -999;


@implementation ConfigValidator {
    MainViewController *controller;
    RXAssistant *rxAssistant;
    NSString *devId;
    
    bool validCharset[256];
    bool firstValidation;
}

- (id)initWithViewController:(MainViewController*)_controller beaconDataReportTo:(RXAssistant*)_rxAssistant andDeviceId:(NSString*)_devId {
    id re = [self init];
    controller = _controller;
    rxAssistant = _rxAssistant;
    devId = _devId;
    for (int i = 0; i < 256; i++)
        validCharset[i] = false;
    for (int i = '0'; i <= '9'; i++)
        validCharset[i] = true;
    for (int i = 'A'; i <= 'F'; i++)
        validCharset[i] = true;
    firstValidation = true;
    return re;
}

- (NSString*)validateConfigContent:(NSString*)content {
    NSArray *lines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    int lineOffset = 0;
    
    // file not exist
    if (lines.count == 0)
        return @"no such configuration file";
    
    // metadata
    bool txenable = true;
    bool rxenable = true;
    bool autoupload = false;
    bool manuallyFlip = false;
    
    while (lineOffset < lines.count && [lines[lineOffset] hasPrefix:@"_"]) {
        if ([lines[lineOffset] isEqualToString:@"_txdisable"])
            txenable = false;
        else if ([lines[lineOffset] isEqualToString:@"_rxdisable"])
            rxenable = false;
        else if ([lines[lineOffset] isEqualToString:@"_autoupload"])
            autoupload = true;
        else if ([lines[lineOffset] isEqualToString:@"_manuallyflip"])
            manuallyFlip = true;
        lineOffset++;
    }
    
    // tx part
    IBeaconIdentifier *txId = [[IBeaconIdentifier alloc] init];

    if (lineOffset == lines.count)
        return [self produceErrorMsg:@"expect tx.uuid" withLineOffset:lineOffset];
    txId.uuid = [[NSUUID alloc] initWithUUIDString:lines[lineOffset]];
    if (txId.uuid == nil)
        return [self produceErrorMsg:@"invalid tx.uuid" withLineOffset:lineOffset];
    lineOffset++;
    //NSLog(@"%@", [txId.uuid UUIDString]);
    
    txId.major = [self checkString:lines[lineOffset] isLegitimateMajorOrMinorAllowDontCare:false];
    if (txId.major == ERROR_CODE)
        return [self produceErrorMsg:@"tx.major is invalid" withLineOffset:lineOffset];
    lineOffset++;
    //NSLog(@"%d", txId.major);
    
    txId.minor = [self checkString:lines[lineOffset] isLegitimateMajorOrMinorAllowDontCare:false];
    if (txId.minor == ERROR_CODE)
        return [self produceErrorMsg:@"tx.major is invalid" withLineOffset:lineOffset];
    lineOffset++;
    //NSLog(@"%d", txId.minor);
    
    // rx part
    NSMutableArray *rxIds = [[NSMutableArray alloc] init];
    
    while (rxIds.count < 20 && lineOffset < lines.count) {
        NSArray *tuple = [lines[lineOffset] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        tuple = [tuple filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
        if (tuple.count == 0)
            break;
        if (tuple.count < 3)
            return [self produceErrorMsg:@"rx element missing" withLineOffset:lineOffset];

        IBeaconIdentifier *rxId = [[IBeaconIdentifier alloc] init];
        rxId.uuid = [[NSUUID alloc] initWithUUIDString:tuple[0]];
        if (rxId.uuid == nil)
            return [self produceErrorMsg:@"invalid rx.uuid" withLineOffset:lineOffset];
        rxId.major = [self checkString:tuple[1] isLegitimateMajorOrMinorAllowDontCare:true];
        if (rxId.major == ERROR_CODE)
            return [self produceErrorMsg:@"invalid rx.major" withLineOffset:lineOffset];
        rxId.minor = [self checkString:tuple[2] isLegitimateMajorOrMinorAllowDontCare:true];
        if (rxId.minor == ERROR_CODE)
            return [self produceErrorMsg:@"invalid rx.minor" withLineOffset:lineOffset];
        
        if (rxId.major == -1 && rxId.minor >= 0)
            return [self produceErrorMsg:@"invalid don't care flag" withLineOffset:lineOffset];
        
        [rxIds addObject:rxId];
        lineOffset++;
    }
    
    if (firstValidation) {
        [controller isNotifiedStartFlagsTxEnable:txenable rxEnable:rxenable autoUpload:autoupload];
        [rxAssistant isNotifiedStartFlagManuallyFlip:manuallyFlip];
    }
    [rxAssistant updateIBeacons:rxIds];
    [controller isNotifiedToSetNewTxId:txId];
    firstValidation = false;
    return nil;
}

- (NSString*)produceErrorMsg:(NSString*)msg withLineOffset:(int)lineOffset {
    return [[NSString alloc] initWithFormat:@"%@, at line %d", msg, lineOffset+1];
}

- (int)checkString:(NSString*)str isLegitimateMajorOrMinorAllowDontCare:(bool)dontCareFlag {
    if ([str isEqualToString:@"0"])
        return 0;
    int t = [str intValue];
    if (t == 0)
        return ERROR_CODE;
    if (t >= 65536)
        return ERROR_CODE;
    if (t > 0)
        return t;
    if (dontCareFlag)
        return -1;
    else
        return ERROR_CODE;
}

@end
