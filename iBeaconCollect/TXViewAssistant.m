//
//  TXViewAssistant.m
//  iBeaconCollect
//
//  Created by Bo Jhang Ho on 9/12/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import "TXViewAssistant.h"

@implementation TXViewAssistant

- (void)setLabelsStaticUuid:(UILabel*)suuid major:(UILabel*)smajor minor:(UILabel*)sminor dynamicUuid:(UILabel*)duuid major:(UILabel*)dmajor minor:(UILabel*)dminor {
    labelTxLUuid = suuid;
    labelTxLMajor = smajor;
    labelTxLMinor = sminor;
    labelTxUuid = duuid;
    labelTxMajor = dmajor;
    labelTxMinor = dminor;
}

- (void)panelAlpha:(double)alpha {
    labelTxLMajor.alpha = alpha;
    labelTxLMinor.alpha = alpha;
    labelTxLUuid.alpha = alpha;
    labelTxMajor.alpha = alpha;
    labelTxMinor.alpha = alpha;
    labelTxUuid.alpha = alpha;
}

- (void)contentColorIsEnabled:(bool)enabled {
    //labelTxLInfo.textColor = color;
    UIColor *color;
    if (enabled)
        color = [UIColor blackColor];
    else
        color = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    labelTxLUuid.textColor = color;
    labelTxUuid.textColor = color;
    labelTxLMajor.textColor = color;
    labelTxMajor.textColor = color;
    labelTxLMinor.textColor = color;
    labelTxMinor.textColor = color;
}

- (void)setContentBeaconId:(IBeaconIdentifier*)txId {
    labelTxUuid.text = txId.uuid.UUIDString;
    labelTxMajor.text = [[NSString alloc] initWithFormat:@"%d", txId.major];
    labelTxMinor.text = [[NSString alloc] initWithFormat:@"%d", txId.minor];
}

@end
