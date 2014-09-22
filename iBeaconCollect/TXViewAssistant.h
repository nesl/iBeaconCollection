//
//  TXViewAssistant.h
//  iBeaconCollect
//
//  Created by Bo Jhang Ho on 9/12/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IBeaconIdentifier.h"

@interface TXViewAssistant : NSObject {
    UILabel *labelTxLUuid;
    UILabel *labelTxLMajor;
    UILabel *labelTxLMinor;
    UILabel *labelTxUuid;
    UILabel *labelTxMajor;
    UILabel *labelTxMinor;
}

- (void)setLabelsStaticUuid:(UILabel*)suuid major:(UILabel*)smajor minor:(UILabel*)sminor dynamicUuid:(UILabel*)duuid major:(UILabel*)dmajor minor:(UILabel*)dminor;
- (void)panelAlpha:(double)alpha;
- (void)contentColorIsEnabled:(bool)enabled;
- (void)setContentBeaconId:(IBeaconIdentifier*)txId;

@end
