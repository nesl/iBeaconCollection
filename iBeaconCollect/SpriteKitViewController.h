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

#import "Utility.h"
#import "LazyFileUploader.h"
#import "DataLogger.h"
#import "UploadManager.h"

@interface SpriteKitViewController : UIViewController <UITextFieldDelegate, CLLocationManagerDelegate, CBPeripheralManagerDelegate> {
    IBOutlet UITextField *textDeviceID;
    IBOutlet UIButton *buttonConnect;
    IBOutlet UILabel *labelLastUpdate;
    IBOutlet UILabel *labelLastConnection;
    IBOutlet UILabel *labelConnectionErrorMessage;
    
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
    IBOutlet UILabel *labelRxLMaj;
    IBOutlet UILabel *labelRxLMin;
    IBOutlet UILabel *labelRxLIn;
    IBOutlet UILabel *labelRxLOut;
    IBOutlet UILabel *labelRxLCnt;
    
    IBOutlet UILabel *labelRxUuid0;
    IBOutlet UILabel *labelRxUuid1;
    IBOutlet UILabel *labelRxUuid2;
    IBOutlet UILabel *labelRxUuid3;
    IBOutlet UILabel *labelRxUuid4;
    IBOutlet UILabel *labelRxUuid5;
    IBOutlet UILabel *labelRxUuid6;
    IBOutlet UILabel *labelRxUuid7;
    IBOutlet UILabel *labelRxUuid8;
    IBOutlet UILabel *labelRxUuid9;
    IBOutlet UILabel *labelRxMajor0;
    IBOutlet UILabel *labelRxMajor1;
    IBOutlet UILabel *labelRxMajor2;
    IBOutlet UILabel *labelRxMajor3;
    IBOutlet UILabel *labelRxMajor4;
    IBOutlet UILabel *labelRxMajor5;
    IBOutlet UILabel *labelRxMajor6;
    IBOutlet UILabel *labelRxMajor7;
    IBOutlet UILabel *labelRxMajor8;
    IBOutlet UILabel *labelRxMajor9;
    IBOutlet UILabel *labelRxMinor0;
    IBOutlet UILabel *labelRxMinor1;
    IBOutlet UILabel *labelRxMinor2;
    IBOutlet UILabel *labelRxMinor3;
    IBOutlet UILabel *labelRxMinor4;
    IBOutlet UILabel *labelRxMinor5;
    IBOutlet UILabel *labelRxMinor6;
    IBOutlet UILabel *labelRxMinor7;
    IBOutlet UILabel *labelRxMinor8;
    IBOutlet UILabel *labelRxMinor9;
    IBOutlet UILabel *labelRxIn0;
    IBOutlet UILabel *labelRxIn1;
    IBOutlet UILabel *labelRxIn2;
    IBOutlet UILabel *labelRxIn3;
    IBOutlet UILabel *labelRxIn4;
    IBOutlet UILabel *labelRxIn5;
    IBOutlet UILabel *labelRxIn6;
    IBOutlet UILabel *labelRxIn7;
    IBOutlet UILabel *labelRxIn8;
    IBOutlet UILabel *labelRxIn9;
    IBOutlet UILabel *labelRxOut0;
    IBOutlet UILabel *labelRxOut1;
    IBOutlet UILabel *labelRxOut2;
    IBOutlet UILabel *labelRxOut3;
    IBOutlet UILabel *labelRxOut4;
    IBOutlet UILabel *labelRxOut5;
    IBOutlet UILabel *labelRxOut6;
    IBOutlet UILabel *labelRxOut7;
    IBOutlet UILabel *labelRxOut8;
    IBOutlet UILabel *labelRxOut9;
    IBOutlet UILabel *labelRxCnt0;
    IBOutlet UILabel *labelRxCnt1;
    IBOutlet UILabel *labelRxCnt2;
    IBOutlet UILabel *labelRxCnt3;
    IBOutlet UILabel *labelRxCnt4;
    IBOutlet UILabel *labelRxCnt5;
    IBOutlet UILabel *labelRxCnt6;
    IBOutlet UILabel *labelRxCnt7;
    IBOutlet UILabel *labelRxCnt8;
    IBOutlet UILabel *labelRxCnt9;
    
    IBOutlet UILabel *labelLAutoUpload;
    IBOutlet UISwitch *switchAutoUpload;
    IBOutlet UIButton *buttonUpload;
    IBOutlet UILabel *labelUploadStatus;
}

@end
