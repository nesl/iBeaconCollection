//
//  RXAssistant.m
//  iBeaconCollect
//
//  Created by Bo Jhang Ho on 9/12/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import "RXAssistant.h"

#import "MainViewController.h"

const double LABEL_RX_X[2][6] = {
    {  3, 177, 203, 226, 260, 282},
    {  3, 177, 203, 232, 263, 292},
};
const double LABEL_RX_WIDTH[2][6] = {
    {185,  30,  30,  43,  30,  44},
    {185,  30,  30,  32,  32,  29},
};
const int TYPE_RANGING = 0;
const int TYPE_MONITORING = 1;
const double LABEL_RX_START_Y = 304.0;
const double LABEL_RX_DELTA_Y = 19.0;
const double LABEL_RX_HEIGHT = 21.0;
const double LABEL_FONT_SIZE = 8.0;
const double LABEL_TITLE_Y = 286.0;
const double LABEL_TITLE_HEIGHT = 21.0;


@implementation RXAssistant {
    MainViewController *controller;
    
    UIColor *colorNotWorking;
    NSArray *titles;
    
    UILabel *labelTitle[6];
    UILabel *labelPool[10][6];
    NSArray *ibeaconIds;
    NSMutableArray *ibeaconStatistics;
    NSTimer *timerChangeUIContent;
    int contentCounter;
    
    bool rxenable;
    
    int totalPage;
    int curPage;
    int contentType;
    
    double timeIntervalFlip;
}

- (id)initWithViewController:(MainViewController *)_controller {
    id re = [self init];
    
    colorNotWorking = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    controller = _controller;
    titles = @[
        @[@"", @"Maj", @"Min", @"Cnt", @"Rssi", @"Dis"],
        @[@"", @"Maj", @"Min", @"In", @"Out", @"Stat"],
    ];
    
    for (int i = 0; i < 6; i++) {
        double tx = LABEL_RX_X[0][i] - 20.0;
        double ty = LABEL_TITLE_Y;
        double tw = LABEL_RX_WIDTH[0][i] + 40.0;
        double th = LABEL_TITLE_HEIGHT;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tx, ty, tw, th) ];
        if (i == 0)
            label.textAlignment = NSTextAlignmentLeft;
        else
            label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:10.0];
        [controller.view addSubview:label];
        label.text = [NSString stringWithFormat: @""];
        label.alpha = 0.0;
        labelTitle[i] = label;
    }
    for (int i = 0; i < 10; i++)
        for (int j = 0; j < 6; j++) {
            double tx = LABEL_RX_X[0][j];
            double ty = LABEL_RX_START_Y + LABEL_RX_DELTA_Y * i;
            double tw = LABEL_RX_WIDTH[0][j];
            double th = LABEL_RX_HEIGHT;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tx, ty, tw, th) ];
            if (j == 0)
                label.textAlignment = NSTextAlignmentLeft;
            else
                label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor blackColor];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont fontWithName:label.font.fontName size:(8.0)];
            [controller.view addSubview:label];
            label.text = [NSString stringWithFormat: @""];
            label.alpha = 0.0;
            labelPool[i][j] = label;
        }
    ibeaconIds = @[];
    ibeaconStatistics = [[NSMutableArray alloc] init];
    
    rxenable = true;
    
    timeIntervalFlip = 3.0;
    
    return re;
}

- (void)updateIBeacons:(NSArray*)beacons {
    bool needUpdate = false;
    if (beacons.count != ibeaconIds.count)
        needUpdate = true;
    else {
        for (int i = 0; i < beacons.count; i++)
            if ([(IBeaconIdentifier*)beacons[i] isEqual:(IBeaconIdentifier*)ibeaconIds[i]] == false)
                needUpdate = true;
    }
    if (needUpdate) {
        [timerChangeUIContent invalidate];
        
        NSArray *oldIbeaconIds = ibeaconIds;
        NSMutableArray *oldIbeaconStatistics = ibeaconStatistics;
        ibeaconIds = beacons;
        ibeaconStatistics = [[NSMutableArray alloc] init];
        for (int i = 0; i < ibeaconIds.count; i++)
            [ibeaconStatistics addObject:[NSNull null]];
        for (int i = 0; i < oldIbeaconIds.count; i++)
            for (int j = 0; j < ibeaconIds.count; j++)
                if ([(IBeaconIdentifier*)oldIbeaconIds[i] isEqual:ibeaconIds[j]]) {
                    ibeaconStatistics[j] = oldIbeaconStatistics[i];
                    oldIbeaconStatistics[i] = [NSNull null];
                }
        for (int i = 0; i < oldIbeaconIds.count; i++)
            if (oldIbeaconStatistics[i] != [NSNull null])
                [controller isNotifiedToStopMonitoringAndRangingARegion:[oldIbeaconIds[i] getRegion]];
        for (int i = 0; i < ibeaconStatistics.count; i++)
            if (ibeaconStatistics[i] == [NSNull null]) {
                ibeaconStatistics[i] = [[IBeaconStatistics alloc] init];
                [controller isNotifiedToStartMonitoringAndRangingARegion:[ibeaconIds[i] getRegion]];
            }
        [timerChangeUIContent invalidate];
        contentCounter = 0;
        [self changeContent];
        if (rxenable && ibeaconStatistics.count > 0) {
            timerChangeUIContent = [NSTimer scheduledTimerWithTimeInterval:timeIntervalFlip
                                                                    target:self
                                                                  selector:@selector(changeContentSignal:)
                                                                  userInfo:nil
                                                                   repeats:YES];
        }
    }
}

- (void)disableRx {
    if (rxenable == true) {
        for (int i = 0; i < 6; i++)
            labelTitle[i].textColor = colorNotWorking;
        for (int i = 0; i < 10; i++) {
            int ind = curPage * 10 + i;
            for (int j = 0; j < 6; j++) {
                if (ind < ibeaconStatistics.count) {
                    labelPool[i][j].alpha = 1.0;
                    labelPool[i][j].textColor = colorNotWorking;
                }
                else {
                    labelPool[i][j].alpha = 0.0;
                }
            }
        }
        for (IBeaconIdentifier *bid in ibeaconIds)
            [controller isNotifiedToStopMonitoringAndRangingARegion:[bid getRegion]];
        [timerChangeUIContent invalidate];
        rxenable = false;
    }
}

- (void)enableRx {
    if (rxenable == false) {
        for (int i = 0; i < 6; i++)
            labelTitle[i].textColor = [UIColor blackColor];
        [self changeContent];
        for (int i = 0; i < 10; i++)
            for (int j = 0; j < 6; j++)
                labelPool[i][j].textColor = [UIColor blackColor];
        if (ibeaconStatistics.count > 0) {
            for (IBeaconIdentifier *bid in ibeaconIds)
                [controller isNotifiedToStartMonitoringAndRangingARegion:[bid getRegion]];
            timerChangeUIContent = [NSTimer scheduledTimerWithTimeInterval:timeIntervalFlip
                                                                    target:self
                                                                  selector:@selector(changeContentSignal:)
                                                                  userInfo:nil
                                                                   repeats:YES];
        }
        rxenable = true;
    }
}

- (void)changeContentSignal:(NSTimer*)timer {
    @synchronized(self) {
        contentCounter++;
        [self changeContent];
    }
}

- (void)changeContent {
    totalPage = ((int)ibeaconStatistics.count + 9) / 10;
    if (totalPage == 0)
        totalPage = 1;
    curPage = (contentCounter / 2) % totalPage;
    contentType = contentCounter % 2;
    [self adjustLabelWidthViaContentType];
    labelTitle[0].text = [self getUuidLabelMsg];
    for (int i = 1; i < 6; i++)
        labelTitle[i].text = titles[contentType][i];
    for (int i = 0; i < 20; i++)
        [self showRowWithBeaconInd:i];
}

- (void)panelAlpha:(double)alpha {
    for (int i = 0; i < 6; i++)
        labelTitle[i].alpha = alpha;
    for (int i = 0; i < 10; i++)
        for (int j = 0; j < 6; j++)
            labelPool[i][j].alpha = alpha;
}

#pragma mark - handling notified events

- (void)notifyRangingEventBeaconId:(IBeaconIdentifier*)recvId rssi:(int)rssi accuracy:(double)acc distance:(CLProximity)dis {
    for (int i = 0; i < ibeaconIds.count; i++) {
        if ( [((IBeaconIdentifier*)ibeaconIds[i]) asARuleToApplyIBeacon:recvId] ) {
            IBeaconStatistics* thisStatistics = (IBeaconStatistics*)ibeaconStatistics[i];
            thisStatistics.nrCnt++;
            thisStatistics.lastRssi = rssi;
            thisStatistics.lastAccuracy = acc;
            thisStatistics.lastDistance = dis;
            [self showRowWithBeaconInd:i];
        }
    }
}

- (void)notifyMonitoringEventIdentifier:(NSString*)identifier isInEvent:(bool)isIn {
    for (int i = 0; i < ibeaconIds.count; i++) {
        IBeaconIdentifier *thisId = (IBeaconIdentifier*)ibeaconIds[i];
        if ([thisId.uuid.UUIDString isEqualToString:identifier]) {
            IBeaconStatistics *thisStat = (IBeaconStatistics*)ibeaconStatistics[i];
            if (isIn) {
                thisStat.nrIn++;
                thisStat.regionStat = CLRegionStateInside;
            }
            else {
                thisStat.nrOut++;
                thisStat.regionStat = CLRegionStateOutside;
            }
        }
    }
}

- (void)notifyWillDetermineState {
    for (int i = 0; i < ibeaconIds.count; i++) {
        IBeaconStatistics* thisStat = ibeaconStatistics[i];
        thisStat.inOutStatus = @"x";
        if (i / 10 == curPage && contentType == TYPE_MONITORING)
            labelPool[i % 10][5].text = thisStat.inOutStatus;
    }
}

- (void)notifyDetermineStateEventIdentifier:(NSString*)identifier state:(CLRegionState)state {
    //NSLog(@"#%@#", identifier);
    for (int i = 0; i < ibeaconIds.count; i++) {
        IBeaconIdentifier *thisId = ibeaconIds[i];
        //NSLog(@"#%@# ?%@?", identifier, [thisId getIdentifierName]);
        if ([[thisId getIdentifierName] isEqualToString:identifier]) {
            IBeaconStatistics *thisStat = ibeaconStatistics[i];
            if (state == CLRegionStateInside)
                thisStat.inOutStatus = @"In";
            else if (state == CLRegionStateOutside)
                thisStat.inOutStatus = @"Out";
            else
                thisStat.inOutStatus = @"?";
            if (rxenable) {
                if (state == CLRegionStateUnknown)
                    thisStat.inOutStatusError = true;
                else if (thisStat.regionStat == CLRegionStateUnknown)
                    thisStat.inOutStatusError = false;
                else if (thisStat.regionStat != state)
                    thisStat.inOutStatusError = true;
                else
                    thisStat.inOutStatusError = false;
            }
            [self showRowWithBeaconInd:i];
        }
    }
}

#pragma mark - label update

- (void)showRowWithBeaconInd:(int)ind {
    if (ind / 10 == curPage) {
        int labelYInd = ind % 10;
        if (ind >= ibeaconStatistics.count) {
            for (int i = 0; i < 6; i++)
                labelPool[labelYInd][i].alpha = 0.0;
        }
        else {
            for (int i = 0; i < 6; i++)
                labelPool[labelYInd][i].alpha = 1.0;
            IBeaconIdentifier *thisIdentifier = (IBeaconIdentifier*)ibeaconIds[ind];
            IBeaconStatistics *thisStatistics = (IBeaconStatistics*)ibeaconStatistics[ind];
            labelPool[labelYInd][0].text = thisIdentifier.uuid.UUIDString;
            labelPool[labelYInd][1].text = [thisIdentifier getMajorString];
            labelPool[labelYInd][2].text = [thisIdentifier getMinorString];
            if (contentType == TYPE_RANGING) {
                labelPool[labelYInd][3].text = [[NSString alloc] initWithFormat:@"%d", thisStatistics.nrCnt];
                labelPool[labelYInd][4].text = [thisStatistics getLastRssiString];
                labelPool[labelYInd][5].text = [thisStatistics getLastDisString];
            }
            else {  // contentType = TYPE_MONITORING
                labelPool[labelYInd][3].text = [[NSString alloc] initWithFormat:@"%d", thisStatistics.nrIn];
                labelPool[labelYInd][4].text = [[NSString alloc] initWithFormat:@"%d", thisStatistics.nrOut];
                labelPool[labelYInd][5].text = thisStatistics.inOutStatus;
                if (rxenable == false)
                    labelPool[labelYInd][5].textColor = colorNotWorking;
                else {
                    if (thisStatistics.inOutStatusError == true)
                        labelPool[labelYInd][5].textColor = [UIColor redColor];
                    else
                        labelPool[labelYInd][5].textColor = [UIColor blackColor];
                }
            }
        }
    }
}

- (void)adjustLabelWidthViaContentType {
    for (int j = 0; j < 6; j++) {
        if (j == 0)
            labelTitle[j].frame = CGRectMake(43, LABEL_TITLE_Y, 145, LABEL_TITLE_HEIGHT);
        else
            labelTitle[j].frame = CGRectMake(LABEL_RX_X[contentType][j] - 20.0, LABEL_TITLE_Y, LABEL_RX_WIDTH[contentType][j] + 40.0, LABEL_TITLE_HEIGHT);
        for (int i = 0; i < 10; i++) {
            labelPool[i][j].frame = CGRectMake(LABEL_RX_X[contentType][j], labelPool[i][j].frame.origin.y, LABEL_RX_WIDTH[contentType][j], labelPool[i][j].frame.size.height);
        }
    }
}

- (NSString*)getUuidLabelMsg {
    if (ibeaconIds.count == 0)
        return @"Uuid";
    NSString *mode;
    if (contentType == TYPE_MONITORING)
        mode = @"Monitoring";
    else // if contentType == TYPE_RANGING
        mode = @"Ranging";
    int s = curPage * 10 + 1;
    int e = curPage * 10 + 10;
    if (e > ibeaconIds.count)
        e = (int)ibeaconIds.count;
    return [[NSString alloc] initWithFormat:@"Uuid (%d-%d %@)", s, e, mode];
}

- (void)isNotifiedToFlipPage {
    @synchronized(self) {
        contentCounter++;
        [self changeContent];
    }
}

- (void)isNotifiedStartFlagManuallyFlip:(bool)manuallyFlip {
    if (manuallyFlip)
        timeIntervalFlip = 1.0e8;
}

@end
