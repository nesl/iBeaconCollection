//
//  SpriteKitViewController.m
//  iBeaconCollect
//
//  Created by Bo Jhang Ho on 6/13/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import "SpriteKitViewController.h"

NSString *ip = @"http://192.168.43.89:8888";

@interface SpriteKitViewController () {
    UILabel *labelRxUuid[10];
    UILabel *labelRxMajor[10];
    UILabel *labelRxMinor[10];
    UILabel *labelRxIn[10];
    UILabel *labelRxOut[10];
    UILabel *labelRxCnt[10];
    
    CLLocationManager *locationManager;
    CBPeripheralManager *peripheralManager;
    NSDateFormatter *dateFormatterScreen;
    
    NSString *txuuid;
    int txmajor;
    int txminor;
    NSString *txidentifier;
    NSDictionary *txbeaconPeripheralData;
    BOOL txenabled;
    
    NSString *rxuuid[20];
    int rxmajor[20];
    int rxminor[20];
    NSString *rxidentifier[20];
    int rxIn[20];
    int rxOut[20];
    int rxCnt[20];
    CLBeaconRegion *rxbeaconRegions[20];
    int rxNr;
    BOOL rxenabled;
    
    NSURLConnection *connectionUpdate;
    NSMutableData *responseDataUpdate;
    
    BOOL successfullyConnectBefore;
    UIColor *colorWorking;
    UIColor *colorNonworking;
}

@end

@implementation SpriteKitViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    colorWorking = [UIColor blackColor];
    colorNonworking = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    [self labelIndex];
    [self showTxRxInfoAlpha:0.0];
    labelLastUpdate.text = @"Last update: --";
    labelLastConnection.text = @"";
    labelConnectionErrorMessage.text = @"";
    [buttonTxEnable setTitle:@"Disable" forState:UIControlStateNormal];
    [buttonRxEnable setTitle:@"Disable" forState:UIControlStateNormal];
    txenabled = true;
    rxenabled = true;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    dateFormatterScreen = [[NSDateFormatter alloc] init];
    [dateFormatterScreen setDateFormat:@"MM/dd HH:mm:ss"];
    textDeviceID.keyboardType = UIKeyboardTypeNumberPad;
	successfullyConnectBefore = false;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        NSLog(@"Powered On");
        [peripheralManager startAdvertising:txbeaconPeripheralData];
    } else if (peripheral.state == CBPeripheralManagerStatePoweredOff) {
        NSLog(@"Powered Off");
        [peripheralManager stopAdvertising];
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    for (int i = 0; i < [beacons count]; i++) {
        CLBeacon *beacon = beacon = beacons[i];
        NSLog(@"%@ %d %d", beacon.proximityUUID.UUIDString, [beacon.major intValue], [beacon.minor intValue]);
        for (int j = 0; j < rxNr; j++) {
            if ([self checkRuleApplyRuuid:rxuuid[j] rmajor:rxmajor[j] rminor:rxminor[j] tuuid:beacon.proximityUUID.UUIDString tmajor:[beacon.major intValue] tminor:[beacon.minor intValue]]) {
                rxCnt[j]++;
                labelRxCnt[j].text = [[NSString alloc] initWithFormat:@"%d", rxCnt[j]];
                //NSLog(@"%d", rxCnt[j]);
            }
        }
        int d;
        switch (beacon.proximity) {
            case CLProximityImmediate:  d = 0;   break;
            case CLProximityNear:       d = 1;   break;
            case CLProximityFar:        d = 2;   break;
            default:                    d = -1;
        }
        [DataLogger putLine:[[NSString alloc] initWithFormat:@"%lf,2,%@,%@,%@,%f,%zi,%d", [NSDate timeIntervalSinceReferenceDate], beacon.proximityUUID.UUIDString, beacon.major, beacon.minor, beacon.accuracy, beacon.rssi, d]];
    }

}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"Beacon Found, with identifier %@", region.identifier);
    for (int i = 0; i < rxNr; i++) {
        //NSLog(@"#%@# ?%@?", rxidentifier[i], region.identifier);
        if ([rxidentifier[i] isEqualToString:region.identifier]) {
            rxIn[i]++;
            labelRxIn[i].text = [[NSString alloc] initWithFormat:@"%d", rxIn[i]];
        }
    }
   [DataLogger putLine:[[NSString alloc] initWithFormat:@"%lf,0,%@,0,0,0,0,0", [NSDate timeIntervalSinceReferenceDate], region.identifier]];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"Left Region, with identifier %@", region.identifier);
    for (int i = 0; i < rxNr; i++) {
        if ([rxidentifier[i] isEqualToString:region.identifier]) {
            rxOut[i]++;
            labelRxOut[i].text = [[NSString alloc] initWithFormat:@"%d", rxOut[i]];
        }
    }
    [DataLogger putLine:[[NSString alloc] initWithFormat:@"%lf,1,%@,0,0,0,0,0", [NSDate timeIntervalSinceReferenceDate], region.identifier]];
}

- (void)startBroadcast {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:txuuid];
    txidentifier = [[NSString alloc] initWithFormat:@"%@_%d_%d", txuuid, txmajor, txminor];
    NSLog(@"%@", txidentifier);
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                           major:txmajor
                                                                           minor:txminor
                                                                      identifier:txidentifier];
    txbeaconPeripheralData = [beaconRegion peripheralDataWithMeasuredPower:nil];
    peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
}

- (void)stopBroadcast {
    [peripheralManager stopAdvertising];
    peripheralManager = nil;
}

- (IBAction)buttonConnectionTouchDown:(id)sender {
    [self.view endEditing:YES];
    if ([textDeviceID.text isEqualToString:@""])
        [self changeLabelErrorMessage:@"DeviceID cannot be empty"];
    else {
        [buttonConnect setEnabled:NO];
        [textDeviceID setEnabled:NO];
        NSString *url = [[NSString alloc] initWithFormat:@"%@/c%@", ip, textDeviceID.text];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        connectionUpdate = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

- (IBAction)buttonTxEnableTouchDown:(id)sender {
    @synchronized (self) {
        if (txenabled == true) {
            txenabled = false;
            [buttonTxEnable setTitle:@"Enabled" forState:UIControlStateNormal];
            [self showTxInfoColor:colorNonworking];
            [self stopBroadcast];
        }
        else {
            txenabled = true;
            [buttonTxEnable setTitle:@"Disabled" forState:UIControlStateNormal];
            [self startBroadcast];
            [self showTxInfoColor:colorWorking];
        }
    }
}

- (IBAction)buttonRxEnableTouchDown:(id)sender {
    @synchronized (self) {
        if (rxenabled == true) {
            rxenabled = false;
            [buttonRxEnable setTitle:@"Enabled" forState:UIControlStateNormal];
            [self showRxInfoColor:colorNonworking];
            for (int i = 0; i < rxNr; i++) {
                [locationManager stopMonitoringForRegion:rxbeaconRegions[i]];
                [locationManager stopRangingBeaconsInRegion:rxbeaconRegions[i]];
            }
        }
        else {
            rxenabled = true;
            [buttonRxEnable setTitle:@"Disabled" forState:UIControlStateNormal];
            [self showRxInfoColor:colorWorking];
            for (int i = 0; i < rxNr; i++) {
                [locationManager startMonitoringForRegion:rxbeaconRegions[i]];
                [locationManager startRangingBeaconsInRegion:rxbeaconRegions[i]];
            }
        }
    }
}

- (IBAction)switchAutoUploadToggle: (id) sender {
    [UploadManager setUploadModeAutomatically:switchAutoUpload.on];
    if (switchAutoUpload.on)
        buttonUpload.alpha = 0.0;
    else
        buttonUpload.alpha = 1.0;
}

- (IBAction)buttonUploadTouchDown:(id)sender {
    NSLog(@"button upload touch down");
    [buttonUpload setEnabled:NO];
    [UploadManager uploadNow];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    //[responseDataUpdate setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == connectionUpdate) {
        @synchronized (self) {
            //[self.responseData appendData:data];
            NSLog(@"didReceiveReceive");
            //NSLog(@"Succeeded! Received %d bytes of data",(int)[data length]);
            //NSLog(@"%@", [NSString stringWithUTF8String:[data bytes]]);
            NSString *input = [NSString stringWithUTF8String:[data bytes]];
            NSScanner *scanner = [NSScanner scannerWithString:input];
            NSString *line;
            NSString *hotxuuid;
            int hotxmajor;
            int hotxminor;
            
            //txuuid
            [scanner scanCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:NULL];
            line = nil;
            [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&line];
            if (line == nil) {
                [self connectionUpdateEndWithErrorMessage:@"expect tx.uuid in line 1"];
                return;
            }
            if ([line isEqualToString:@"failed"]) {
                [self connectionUpdateEndWithErrorMessage:@"no such configuration file"];
                return;
            }
            hotxuuid = [[line uppercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSLog(@"%@", hotxuuid);
            
            //txmajor
            [scanner scanCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:NULL];
            line = nil;
            [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&line];
            if (line == nil) {
                [self connectionUpdateEndWithErrorMessage:@"expect tx.major in line 2"];
                return;
            }
            hotxmajor = [line intValue];
            if (hotxmajor == 0) {
                [self connectionUpdateEndWithErrorMessage:@"tx.major is zero or invalid"];
                return;
            }
            NSLog(@"%d", hotxmajor);
            
            //txminor
            [scanner scanCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:NULL];
            line = nil;
            [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&line];
            if (line == nil) {
                [self connectionUpdateEndWithErrorMessage:@"expect tx.minor in line 3"];
                return;
            }
            hotxminor = [line intValue];
            if (hotxminor == 0) {
                [self connectionUpdateEndWithErrorMessage:@"tx.minor is zero or invalid"];
                return;
            }
            NSLog(@"%d", hotxminor);
            
            // rx parts
            NSString *horxuuid[20];
            int horxmajor[20];
            int horxminor[20];
            int horxin[20];
            int horxout[20];
            int horxcnt[20];
            int horxNr = 0;

            do {
                [scanner scanCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:NULL];
                line = nil;
                [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&line];
                if (line != nil) {
                    const char *c = [line UTF8String];
                    char tuuid[1000];
                    int tmajor;
                    int tminor;
                    int re = sscanf(c, "%s %d %d", tuuid, &tmajor, &tminor);
                    if (tmajor < 0)
                        tmajor = -1;
                    if (tminor < 0)
                        tminor = -1;
                    if (re == 0)
                        break;
                    else if (re != 3) {
                        [self changeLabelErrorMessage:[[NSString alloc] initWithFormat:@"wrong format in rx line %d", horxNr+1]];
                        return;
                    }
                    else {
                        //NSLog(@"%s %d %d", tuuid, tmajor, tminor);
                        horxuuid[horxNr] = [[[NSString alloc] initWithFormat:@"%s", tuuid] uppercaseString];
                        horxmajor[horxNr] = tmajor;
                        horxminor[horxNr] = tminor;
                        horxin[horxNr] = 0;
                        horxout[horxNr] = 0;
                        horxcnt[horxNr] = 0;
                        horxNr++;
                    }
                }
            } while (horxNr < 20 && line != nil);
            
            // handover
            if (txenabled) {
                [self stopBroadcast];
            }
            if (rxenabled) {
                for (int i = 0; i < rxNr; i++) {
                    [locationManager stopMonitoringForRegion:rxbeaconRegions[i]];
                    [locationManager stopRangingBeaconsInRegion:rxbeaconRegions[i]];
                }
            }
            
            for (int i = 0; i < rxNr; i++) {
                for (int j = 0; j < horxNr; j++) {
                    if ([rxuuid[i] isEqualToString:horxuuid[j]] && rxmajor[i] == horxmajor[j] && rxminor[i] == horxminor[j]) {
                        horxin[j] = rxIn[i];
                        horxout[j] = rxOut[i];
                        horxcnt[j] = rxCnt[i];
                    }
                }
            }
            txuuid = hotxuuid;
            txmajor = hotxmajor;
            txminor = hotxminor;
            rxNr = horxNr;
            for (int i = 0; i < horxNr; i++) {
                rxuuid[i] = horxuuid[i];
                rxmajor[i] = horxmajor[i];
                rxminor[i] = horxminor[i];
                rxIn[i] = horxin[i];
                rxOut[i] = horxout[i];
                rxCnt[i] = horxcnt[i];
            }
            
            if (txenabled) {
                [self startBroadcast];
            }
            for (int i = 0; i < rxNr; i++) {
                NSUUID *tuuid = [[NSUUID alloc] initWithUUIDString:rxuuid[i]];
                rxidentifier[i] = [[NSString alloc] initWithFormat:@"%@_%d_%d", rxuuid[i], rxmajor[i], rxminor[i]];
                CLBeaconRegion *tbeaconRegion;
                if (rxmajor[i] == -1 && rxminor[i] == -1)
                    tbeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:tuuid identifier:rxidentifier[i]];
                else if (rxminor[i] == -1)
                    tbeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:tuuid major:rxmajor[i] identifier:rxidentifier[i]];
                else
                    tbeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:tuuid major:rxmajor[i] minor:rxminor[i] identifier:rxidentifier[i]];
                tbeaconRegion.notifyOnEntry = YES;
                tbeaconRegion.notifyOnExit = YES;
                tbeaconRegion.notifyEntryStateOnDisplay = YES;
                rxbeaconRegions[i] = tbeaconRegion;
                if (rxenabled) {
                    [locationManager startMonitoringForRegion:rxbeaconRegions[i]];
                    [locationManager startRangingBeaconsInRegion:rxbeaconRegions[i]];
                }
            }
            
            labelTxUuid.text = txuuid;
            labelTxMajor.text = [[NSString alloc] initWithFormat:@"%d", txmajor];
            labelTxMinor.text = [[NSString alloc] initWithFormat:@"%d", txminor];
            for (int i = 0; i < 10; i++) {
                if (i < rxNr) {
                    labelRxUuid[i].text = rxuuid[i];
                    if (rxmajor[i] != -1)
                        labelRxMajor[i].text = [[NSString alloc] initWithFormat:@"%d", rxmajor[i]];
                    else
                        labelRxMajor[i].text = @"*";
                    if (rxminor[i] != -1)
                        labelRxMinor[i].text = [[NSString alloc] initWithFormat:@"%d", rxminor[i]];
                    else
                        labelRxMinor[i].text = @"*";
                    labelRxIn[i].text = [[NSString alloc] initWithFormat:@"%d", rxIn[i]];
                    labelRxOut[i].text = [[NSString alloc] initWithFormat:@"%d", rxOut[i]];
                    labelRxCnt[i].text = [[NSString alloc] initWithFormat:@"%d", rxCnt[i]];
                }
                else {
                    labelRxUuid[i].text = @"";
                    labelRxMajor[i].text = @"";
                    labelRxMinor[i].text = @"";
                    labelRxIn[i].text = @"";
                    labelRxOut[i].text = @"";
                    labelRxCnt[i].text = @"";
                }
            }
            [self connectionUpdateEndWithErrorMessage:nil];
        }
    }
}

- (void)connectionUpdateEndWithErrorMessage:(NSString*)message {
    //NSLog(@"end 0");
    if (successfullyConnectBefore == false) {
        if (message != nil) {
            //NSLog(@"end 1");
            [textDeviceID setEnabled:YES];
            [buttonConnect setEnabled:YES];
        }
        else {
            buttonConnect.alpha = 0.0;
            [textDeviceID setEnabled:NO];
            [self showTxRxInfoAlpha:1.0];
            successfullyConnectBefore = true;
            [DataLogger globalInit:textDeviceID.text];
            //NSLog(@"end 2 %@", textDeviceID.text);
            [NSTimer scheduledTimerWithTimeInterval:15
                                             target:self
                                           selector:@selector(reloadConfigurationFile:)
                                           userInfo:nil
                                            repeats:YES];
            NSString *url = [[NSString alloc] initWithFormat:@"%@/u", ip];
            //NSLog(@"end 2.2");
            [self initializeUploadManagerPrefix:url];
            //NSLog(@"end 2.3");
        }
    }
    [self changeLabelErrorMessage:message];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog([NSString stringWithFormat:@"Connection failed: %@", [error description]]);
    if (connection == connectionUpdate) {
        [self changeLabelErrorMessage:@"network connection error"];
        [buttonConnect setEnabled:YES];
        [textDeviceID setEnabled:YES];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
}

- (void)changeLabelErrorMessage:(NSString*)msg {
    if (msg == nil) {
        labelLastUpdate.text = [[NSString alloc] initWithFormat:@"Last update: %@", [dateFormatterScreen stringFromDate:[NSDate date]]];
        labelLastConnection.text = @"";
        labelConnectionErrorMessage.text = @"";
    }
    else {
        labelLastConnection.text = [[NSString alloc] initWithFormat:@"Last connection: %@", [dateFormatterScreen stringFromDate:[NSDate date]]];
        labelConnectionErrorMessage.text = [[NSString alloc] initWithFormat:@"Error: %@", msg];
    }
}

- (BOOL)checkRuleApplyRuuid:(NSString*)ruuid rmajor:(int)rmajor rminor:(int)rminor tuuid:(NSString*)tuuid tmajor:(int)tmajor tminor:(int)tminor {
    bool condUuid = [ruuid isEqualToString:tuuid];
    bool condMajor = (rmajor == -1 || tmajor == rmajor);
    bool condMinor = (rminor == -1 || tminor == rminor);
    return condUuid && condMajor && condMinor;
}

- (void)reloadConfigurationFile:(NSTimer*)timer {
    NSString *url = [[NSString alloc] initWithFormat:@"%@/c%@", ip, textDeviceID.text];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    connectionUpdate = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)initializeUploadManagerPrefix:(NSString*)prefix {
    [UploadManager globalInitWithIpPortPrefix:prefix];
    [UploadManager addUploadWillStartBlock:^(int nrToUpload) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [buttonUpload setEnabled:NO];
            labelUploadStatus.textColor = [UIColor blackColor];
            labelUploadStatus.text = @"Server connecting...";
        });
    }];
    [UploadManager addDidUploadBlock:^(int nrFinished, int total, bool isAutoMode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            labelUploadStatus.text = [[NSString alloc] initWithFormat:@"Uploading %d of %d", nrFinished, total];
        });
    }];
    [UploadManager addUploadFailedBlock:^(int nrFinished, int total, bool isAutoMode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *umode = (isAutoMode ? @"Automatically" : @"Manually");
            labelUploadStatus.text = [[NSString alloc] initWithFormat:@"%@ uploading failed at %@ (%d uploaded, %d failed)", umode, [dateFormatterScreen stringFromDate:[NSDate date]], nrFinished, total - nrFinished];
            [buttonUpload setEnabled:YES];
            labelUploadStatus.textColor = [UIColor redColor];
        });
    }];
    [UploadManager addUploadAllSucceededBlock:^(int total, bool isAutoMode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *umode = (isAutoMode ? @"Automatically" : @"Manually");
            labelUploadStatus.text = [[NSString alloc] initWithFormat:@"%@ uploading successfully at %@ (%d in total)", umode, [dateFormatterScreen stringFromDate:[NSDate date]], total];
            [buttonUpload setEnabled:YES];
        });
    }];
    [UploadManager addNothingToUploadBlock:^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            labelUploadStatus.text = @"Nothing to upload...";
            [buttonUpload setEnabled:YES];
        });
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (void)labelIndex {
    labelRxUuid[0] = labelRxUuid0;
    labelRxUuid[1] = labelRxUuid1;
    labelRxUuid[2] = labelRxUuid2;
    labelRxUuid[3] = labelRxUuid3;
    labelRxUuid[4] = labelRxUuid4;
    labelRxUuid[5] = labelRxUuid5;
    labelRxUuid[6] = labelRxUuid6;
    labelRxUuid[7] = labelRxUuid7;
    labelRxUuid[8] = labelRxUuid8;
    labelRxUuid[9] = labelRxUuid9;
    labelRxMajor[0] = labelRxMajor0;
    labelRxMajor[1] = labelRxMajor1;
    labelRxMajor[2] = labelRxMajor2;
    labelRxMajor[3] = labelRxMajor3;
    labelRxMajor[4] = labelRxMajor4;
    labelRxMajor[5] = labelRxMajor5;
    labelRxMajor[6] = labelRxMajor6;
    labelRxMajor[7] = labelRxMajor7;
    labelRxMajor[8] = labelRxMajor8;
    labelRxMajor[9] = labelRxMajor9;
    labelRxMinor[0] = labelRxMinor0;
    labelRxMinor[1] = labelRxMinor1;
    labelRxMinor[2] = labelRxMinor2;
    labelRxMinor[3] = labelRxMinor3;
    labelRxMinor[4] = labelRxMinor4;
    labelRxMinor[5] = labelRxMinor5;
    labelRxMinor[6] = labelRxMinor6;
    labelRxMinor[7] = labelRxMinor7;
    labelRxMinor[8] = labelRxMinor8;
    labelRxMinor[9] = labelRxMinor9;
    labelRxIn[0] = labelRxIn0;
    labelRxIn[1] = labelRxIn1;
    labelRxIn[2] = labelRxIn2;
    labelRxIn[3] = labelRxIn3;
    labelRxIn[4] = labelRxIn4;
    labelRxIn[5] = labelRxIn5;
    labelRxIn[6] = labelRxIn6;
    labelRxIn[7] = labelRxIn7;
    labelRxIn[8] = labelRxIn8;
    labelRxIn[9] = labelRxIn9;
    labelRxOut[0] = labelRxOut0;
    labelRxOut[1] = labelRxOut1;
    labelRxOut[2] = labelRxOut2;
    labelRxOut[3] = labelRxOut3;
    labelRxOut[4] = labelRxOut4;
    labelRxOut[5] = labelRxOut5;
    labelRxOut[6] = labelRxOut6;
    labelRxOut[7] = labelRxOut7;
    labelRxOut[8] = labelRxOut8;
    labelRxOut[9] = labelRxOut9;
    labelRxCnt[0] = labelRxCnt0;
    labelRxCnt[1] = labelRxCnt1;
    labelRxCnt[2] = labelRxCnt2;
    labelRxCnt[3] = labelRxCnt3;
    labelRxCnt[4] = labelRxCnt4;
    labelRxCnt[5] = labelRxCnt5;
    labelRxCnt[6] = labelRxCnt6;
    labelRxCnt[7] = labelRxCnt7;
    labelRxCnt[8] = labelRxCnt8;
    labelRxCnt[9] = labelRxCnt9;
}

- (void)showTxRxInfoAlpha:(double)alpha {
    for (int i = 0; i < 10; i++) {
        labelRxUuid[i].alpha = alpha;
        labelRxMajor[i].alpha = alpha;
        labelRxMinor[i].alpha = alpha;
        labelRxIn[i].alpha = alpha;
        labelRxOut[i].alpha = alpha;
        labelRxCnt[i].alpha = alpha;
    }
    labelTxLInfo.alpha = alpha;
    labelTxLMajor.alpha = alpha;
    labelTxLMinor.alpha = alpha;
    labelTxLUuid.alpha = alpha;
    labelTxMajor.alpha = alpha;
    labelTxMinor.alpha = alpha;
    labelTxUuid.alpha = alpha;
    labelRxLInfo.alpha = alpha;
    labelRxLMaj.alpha = alpha;
    labelRxLMin.alpha = alpha;
    labelRxLIn.alpha = alpha;
    labelRxLOut.alpha = alpha;
    labelRxLCnt.alpha = alpha;
    buttonTxEnable.alpha = alpha;
    buttonRxEnable.alpha = alpha;
    labelLAutoUpload.alpha = alpha;
    switchAutoUpload.alpha = alpha;
    buttonUpload.alpha = alpha;
}

- (void)showTxInfoColor:(UIColor*)color {
    //labelTxLInfo.textColor = color;
    labelTxLUuid.textColor = color;
    labelTxUuid.textColor = color;
    labelTxLMajor.textColor = color;
    labelTxMajor.textColor = color;
    labelTxLMinor.textColor = color;
    labelTxMinor.textColor = color;
}

- (void)showRxInfoColor:(UIColor*)color {
    //labelRxLInfo.textColor = color;
    labelRxLMaj.textColor = color;
    labelRxLMin.textColor = color;
    labelRxLIn.textColor = color;
    labelRxLOut.textColor = color;
    labelRxLCnt.textColor = color;
    for (int i = 0; i < 10; i++) {
        labelRxUuid[i].textColor = color;
        labelRxMajor[i].textColor = color;
        labelRxMinor[i].textColor = color;
        labelRxIn[i].textColor = color;
        labelRxOut[i].textColor = color;
        labelRxCnt[i].textColor = color;
    }
}

@end
