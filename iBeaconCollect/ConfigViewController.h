//
//  ConfigViewController.h
//  iBeaconCollect
//
//  Created by Bo Jhang Ho on 9/7/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IPController.h"

@protocol ReloadIPDelegate <NSObject>

-(void)signalReloadIP;

@end


@interface ConfigViewController : UIViewController {
    IBOutlet UITextField *textIpPort;
}


@property(nonatomic,assign) id delegate;


@end
