//
//  SpriteKitViewController.h
//  iBeaconCollect
//
//  Created by Bo Jhang Ho on 6/13/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "ConfigViewController.h"

#import "Utility.h"
#import "LazyFileUploader.h"
#import "DataLogger.h"
#import "UploadManager.h"
#import "ConfigCache.h"
#import "ConfigValidator.h"
#import "IBeaconIdentifier.h"
#import "TXViewAssistant.h"
#import "RXAssistant.h"
//#import "InfoRestoreHandler.h"

@interface MainViewController : UIViewController <UITextFieldDelegate, CLLocationManagerDelegate, CBPeripheralManagerDelegate, ReloadIPDelegate> {
    IBOutlet UITextField *textDeviceID;
    IBOutlet UIButton *buttonConnect;
    IBOutlet UILabel *labelLastUpdate;
    IBOutlet UILabel *labelLastConnection;
    IBOutlet UILabel *labelConnectionErrorMessage;
    
    IBOutlet UILabel *labelServerIP;
    IBOutlet UIButton *buttonChangeIP;
    
    IBOutlet UILabel *labelTxLInfo;
    IBOutlet UIButton *buttonTxEnable;
    IBOutlet UILabel *labelTxLUuid;
    IBOutlet UILabel *labelTxLMajor;
    IBOutlet UILabel *labelTxLMinor;
    IBOutlet UILabel *labelTxUuid;
    IBOutlet UILabel *labelTxMajor;
    IBOutlet UILabel *labelTxMinor;
    
    IBOutlet UILabel *labelRxLInfo;
    IBOutlet UIButton *buttonRxEnable;
    
    IBOutlet UIButton *buttonSkipFirstConnection;
    
    IBOutlet UILabel *labelLAutoUpload;
    IBOutlet UISwitch *switchAutoUpload;
    IBOutlet UIButton *buttonUpload;
    IBOutlet UILabel *labelUploadStatus;
    
    IBOutlet UILabel *labelNowTime;
}

//@property(readonly, getter=view) UIView pubview;  // this will cause error! but why????????

- (void)isNotifiedStartFlagsTxEnable:(bool)flagTxEnable rxEnable:(bool)flagRxEnable autoUpload:(bool)flagAutoUpload;
- (void)isNotifiedToSetNewTxId:(IBeaconIdentifier*)newTxId;
- (void)isNotifiedToStartMonitoringAndRangingARegion:(CLBeaconRegion*)region;
- (void)isNotifiedToStopMonitoringAndRangingARegion:(CLBeaconRegion*)region;

@end
