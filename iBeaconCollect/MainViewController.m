//
//  SpriteKitViewController.m
//  iBeaconCollect
//
//  Created by Bo Jhang Ho on 6/13/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import "MainViewController.h"


@interface MainViewController () {
    NSString *ip;
    
    CLLocationManager *locationManager;
    CBPeripheralManager *peripheralManager;
    NSDateFormatter *dateFormatterScreen;
    
    IBeaconIdentifier *txId;
    NSDictionary *txbeaconPeripheralData;
    
    TXViewAssistant *txAssistant;
    RXAssistant *rxAssistant;
    BOOL txenabled;
    BOOL rxenabled;
    
    ConfigCache *configCacher;
    ConfigValidator *configValidator;
    
    NSURLConnection *connectionUpdate;
    NSMutableData *responseDataUpdate;
    
    BOOL successfullyConnectBefore;
    UIColor *colorWorking;
    UIColor *colorNonworking;
}

@end

@implementation MainViewController


#pragma mark - iOS view handler

- (void)viewDidLoad {
    [super viewDidLoad];
    
    colorWorking = [UIColor blackColor];
    colorNonworking = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    labelLastUpdate.text = @"Last update: --";
    labelLastConnection.text = @"";
    labelConnectionErrorMessage.text = @"";
    locationManager = [[CLLocationManager alloc] init];
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
    locationManager.delegate = self;
    
    
    txAssistant = [[TXViewAssistant alloc] init];
    [txAssistant setLabelsStaticUuid:labelTxLUuid major:labelTxLMajor minor:labelTxLMinor dynamicUuid:labelTxUuid major:labelTxMajor minor:labelTxMinor];
    rxAssistant = [[RXAssistant alloc] initWithViewController:self];
    [self dataDisplayPanelAlpha:0.0];
    buttonSkipFirstConnection.alpha = 0.0;
    
    [buttonTxEnable setTitle:@"Disable" forState:UIControlStateNormal];
    [buttonRxEnable setTitle:@"Disable" forState:UIControlStateNormal];
    txenabled = true;
    rxenabled = true;
    
    configCacher = [[ConfigCache alloc] init];
    dateFormatterScreen = [[NSDateFormatter alloc] init];
    [dateFormatterScreen setDateFormat:@"MM/dd HH:mm:ss"];
    textDeviceID.keyboardType = UIKeyboardTypeNumberPad;
	successfullyConnectBefore = false;
    [self signalReloadIP];
    
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(updateCurrentTime:)
                                   userInfo:nil
                                    repeats:YES];
    
    [self.view setMultipleTouchEnabled:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"from here");
    ConfigViewController* foreignController = (ConfigViewController*)[segue destinationViewController];
    foreignController.delegate = self;
}

- (void)viewWillAppear {
    NSLog(@"view appera");
}



#pragma mark - Bluetooth handling

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        NSLog(@"Powered On");
        [peripheralManager startAdvertising:txbeaconPeripheralData];
    } else if (peripheral.state == CBPeripheralManagerStatePoweredOff) {
        NSLog(@"Powered Off");
        [peripheralManager stopAdvertising];
    }
}

- (void)startBroadcast {
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:txId.uuid
                                                                           major:txId.major
                                                                           minor:txId.minor
                                                                      identifier:[txId getIdentifierName]];
    txbeaconPeripheralData = [beaconRegion peripheralDataWithMeasuredPower:nil];
    peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
}

- (void)stopBroadcast {
    [peripheralManager stopAdvertising];
    peripheralManager = nil;
}



#pragma mark - LocationManager reports

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    for (int i = 0; i < [beacons count]; i++) {
        CLBeacon *beacon = beacon = beacons[i];
        NSLog(@"Beacon ranging, major=%d, minor=%d", [beacon.major intValue], [beacon.minor intValue]);
        IBeaconIdentifier *tid = [[IBeaconIdentifier alloc] init];
        tid.uuid = beacon.proximityUUID;
        tid.major = [beacon.major intValue];
        tid.minor = [beacon.minor intValue];
        [rxAssistant notifyRangingEventBeaconId:tid rssi:(int)beacon.rssi accuracy:beacon.accuracy distance:beacon.proximity];
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
    [rxAssistant notifyMonitoringEventIdentifier:region.identifier isInEvent:true];
    [DataLogger putLine:[[NSString alloc] initWithFormat:@"%lf,0,%@,0,0,0,0,0", [NSDate timeIntervalSinceReferenceDate], region.identifier]];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"Left Region, with identifier %@", region.identifier);
    [rxAssistant notifyMonitoringEventIdentifier:region.identifier isInEvent:false];
    [DataLogger putLine:[[NSString alloc] initWithFormat:@"%lf,1,%@,0,0,0,0,0", [NSDate timeIntervalSinceReferenceDate], region.identifier]];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    [rxAssistant notifyDetermineStateEventIdentifier:region.identifier state:state];
    
    int lno;
    if (state == CLRegionStateInside) {
        //NSLog(@"state of region %@ is inside", region.identifier);
        lno = 0;
    }
    else if (state == CLRegionStateOutside) {
        //NSLog(@"state of region %@ is outside", region.identifier);
        lno = 1;
    }
    else {
        //NSLog(@"state of region %@ is unknown", region.identifier);
        lno = -1;
    }
    
    [DataLogger putLine:[[NSString alloc] initWithFormat:@"%lf,10,%@,%d,0,0,0,0", [NSDate timeIntervalSinceReferenceDate], region.identifier, lno]];

}

- (void)checkAllRegionInOut {
    @synchronized (self) {
        [rxAssistant notifyWillDetermineState];
        NSSet *set = [locationManager monitoredRegions];
        //NSLog(@"find total %zd regions", [set count]);
        for (CLRegion* region in set) {
            //NSLog(@"find region %@", region.identifier);
            [locationManager requestStateForRegion:region];
        }
    }
}

- (void)checkAllRegionInOut:(NSTimer*)timer {
    [self checkAllRegionInOut];
}



#pragma mark - Button and switches events

- (IBAction)buttonConnectionTouchDown:(id)sender {
    [self.view endEditing:YES];
    if ([textDeviceID.text isEqualToString:@""])
        [self changeLabelErrorMessage:@"DeviceID cannot be empty"];
    else {
        [buttonConnect setEnabled:NO];
        [textDeviceID setEnabled:NO];
        [buttonChangeIP setEnabled:NO];
        [buttonSkipFirstConnection setEnabled:NO];
        NSString *url = [[NSString alloc] initWithFormat:@"%@/c%@", ip, textDeviceID.text];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        connectionUpdate = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        configValidator = [[ConfigValidator alloc] initWithViewController:self beaconDataReportTo:rxAssistant andDeviceId:textDeviceID.text];
    }
}

- (IBAction)buttonTxEnableTouchDown:(id)sender {
    @synchronized (self) {
        if (txenabled == true) {
            txenabled = false;
            [buttonTxEnable setTitle:@"Enabled" forState:UIControlStateNormal];
            [txAssistant contentColorIsEnabled:false];
            [self stopBroadcast];
        }
        else {
            txenabled = true;
            [buttonTxEnable setTitle:@"Disabled" forState:UIControlStateNormal];
            [txAssistant contentColorIsEnabled:true];
            [self startBroadcast];
        }
    }
}

- (IBAction)buttonRxEnableTouchDown:(id)sender {
    @synchronized (self) {
        if (rxenabled == true) {
            rxenabled = false;
            [buttonRxEnable setTitle:@"Enabled" forState:UIControlStateNormal];
            [rxAssistant disableRx];
        }
        else {
            rxenabled = true;
            [buttonRxEnable setTitle:@"Disabled" forState:UIControlStateNormal];
            [rxAssistant enableRx];
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
    [buttonUpload setEnabled:NO];
    [UploadManager uploadNow];
}

- (IBAction)textDeviceIdChange:(id)sender {
    if ([configCacher checkConfigFileExistWithDevId:textDeviceID.text])
        buttonSkipFirstConnection.alpha = 1.0;
    else
        buttonSkipFirstConnection.alpha = 0.0;
}

- (void)updateCurrentTime:(NSTimer*)timer {
    labelNowTime.text = [[NSString alloc] initWithFormat:@"Current time: %@", [dateFormatterScreen stringFromDate:[NSDate date]]];
}

- (IBAction)buttonSkipFirstConnectionTouchDown:(id)sender {
    [buttonConnect setEnabled:NO];
    [textDeviceID setEnabled:NO];
    [buttonChangeIP setEnabled:NO];
    [buttonSkipFirstConnection setEnabled:NO];
    configValidator = [[ConfigValidator alloc] initWithViewController:self beaconDataReportTo:rxAssistant andDeviceId:textDeviceID.text];
    NSString *configContent = [configCacher loadConfigFileWithDevId:textDeviceID.text];
    NSString *errMsg = [configValidator validateConfigContent:configContent];
    [self connectionUpdateEndWithErrorMessage:errMsg];
}

#pragma mark - Configuration file connection

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    [responseDataUpdate setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == connectionUpdate) {
        NSString *input = [NSString stringWithUTF8String:[data bytes]];
        //NSLog(@"Succeeded! Received %d bytes of data",(int)[data length]);
        @synchronized (self) {
            NSString *errMsg = [configValidator validateConfigContent:input];
            [self connectionUpdateEndWithErrorMessage:errMsg];
            if (errMsg == nil)
                [configCacher saveConfigFileWithDevId:textDeviceID.text content:input];
        }
    }
}

- (void)connectionUpdateEndWithErrorMessage:(NSString*)message {
    if (successfullyConnectBefore == false) {
        if (message != nil) {
            [textDeviceID setEnabled:YES];
            [buttonConnect setEnabled:YES];
            [buttonChangeIP setEnabled:YES];
            [buttonSkipFirstConnection setEnabled:YES];
        }
        else {
            buttonConnect.alpha = 0.0;
            [textDeviceID setEnabled:NO];
            [self dataDisplayPanelAlpha:1.0];
            labelServerIP.alpha = 0.0;
            buttonChangeIP.frame = CGRectMake(-60, 550, 59, 19);
            buttonChangeIP.titleLabel.font = [UIFont systemFontOfSize:10];
            [UIView animateWithDuration:0.5f animations:^{
                [buttonChangeIP setFrame:CGRectMake(0, 550, 59, 19)];
            }];
            [buttonChangeIP setTitle:@"Change IP" forState:UIControlStateNormal];
            [buttonChangeIP setEnabled:YES];
            buttonSkipFirstConnection.alpha = 0.0;
            successfullyConnectBefore = true;
            [DataLogger globalInit:textDeviceID.text];
            [NSTimer scheduledTimerWithTimeInterval:15
                                             target:self
                                           selector:@selector(reloadConfigurationFile:)
                                           userInfo:nil
                                            repeats:YES];
            NSString *url = [[NSString alloc] initWithFormat:@"%@/u", ip];
            [self initializeUploadManagerPrefix:url];
            [NSTimer scheduledTimerWithTimeInterval:5
                                             target:self
                                           selector:@selector(checkAllRegionInOut:)
                                           userInfo:nil
                                            repeats:YES];
        }
    }
    [self changeLabelErrorMessage:message];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog(@"Connection failed: %@", [error description]);
    if (connection == connectionUpdate) {
        [self connectionUpdateEndWithErrorMessage:@"network connection error"];
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

- (void)reloadConfigurationFile:(NSTimer*)timer {
    NSString *url = [[NSString alloc] initWithFormat:@"%@/c%@", ip, textDeviceID.text];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    connectionUpdate = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}



#pragma mark - UUID rule match

- (BOOL)checkRuleApplyRuuid:(NSString*)ruuid rmajor:(int)rmajor rminor:(int)rminor tuuid:(NSString*)tuuid tmajor:(int)tmajor tminor:(int)tminor {
    bool condUuid = [ruuid isEqualToString:tuuid];
    bool condMajor = (rmajor == -1 || tmajor == rmajor);
    bool condMinor = (rminor == -1 || tminor == rminor);
    return condUuid && condMajor && condMinor;
}



#pragma mark - Upload sensed file back to server

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




#pragma mark - Keyboard handler

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
    if (successfullyConnectBefore) {
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint location = [touch locationInView:touch.view];
        if (rxenabled && 300.0 <= location.y && location.y <= 490.0)
            [rxAssistant isNotifiedToFlipPage];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Dialog

/*
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    ip = [[NSString alloc] initWithFormat:@"http://%@", [[alertView textFieldAtIndex:0] text]];
    // TODO: check ip is validate, [InfoRestoreHandler checkip]
    labelServerIP.text = ip;
    [InfoRestoreHandler commitIPPort:[[alertView textFieldAtIndex:0] text]];
}
*/

- (void)dataDisplayPanelAlpha:(double)alpha {
    buttonTxEnable.alpha = alpha;
    labelTxLInfo.alpha = alpha;
    [txAssistant panelAlpha:alpha];
    
    buttonRxEnable.alpha = alpha;
    labelRxLInfo.alpha = alpha;
    [rxAssistant panelAlpha:alpha];
    
    labelLAutoUpload.alpha = alpha;
    switchAutoUpload.alpha = alpha;
    buttonUpload.alpha = alpha;
}

# pragma mark - signal from ConfigValidator

- (void)isNotifiedToSetNewTxId:(IBeaconIdentifier*)newTxId {
    if (txId == nil || [txId isEqual:newTxId] == false) {
        txId = newTxId;
        NSLog(@"come here and modify tx");
        [txAssistant setContentBeaconId:newTxId];
        if (txenabled) {
            [self stopBroadcast];
            [self startBroadcast];
        }
    }
}

- (void)isNotifiedStartFlagsTxEnable:(bool)flagTxEnable rxEnable:(bool)flagRxEnable autoUpload:(bool)flagAutoUpload {
    NSLog(@"flags: %d %d %d", flagTxEnable, flagRxEnable, flagAutoUpload);
    if (flagTxEnable == false)
        [self buttonTxEnableTouchDown:nil];
    if (flagRxEnable == false)
        [self buttonRxEnableTouchDown:nil];
    if (flagAutoUpload == true)
        [switchAutoUpload setOn:YES animated:YES];
}

# pragma mark signal from RXAssistant

- (void)isNotifiedToStartMonitoringAndRangingARegion:(CLBeaconRegion*)region {
    NSLog(@"start mr %@ %d", region.identifier, region.notifyOnEntry);
    [locationManager startMonitoringForRegion:region];
    [locationManager startRangingBeaconsInRegion:region];
}

- (void)isNotifiedToStopMonitoringAndRangingARegion:(CLBeaconRegion*)region {
    [locationManager stopMonitoringForRegion:region];
    [locationManager stopRangingBeaconsInRegion:region];
}

# pragma mark - implemented protocols

- (void)signalReloadIP {
    ip = [[IPController getInstance] firstIPPort];
    labelServerIP.text = ip;
}

@end
