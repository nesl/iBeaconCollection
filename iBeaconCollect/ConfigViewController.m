//
//  ConfigViewController.m
//  iBeaconCollect
//
//  Created by Bo Jhang Ho on 9/7/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import "ConfigViewController.h"


const double POS_X_FIRST_HTTP_LABEL = 37.0;
const double POS_Y_FIRST_HTTP_LABEL = 291.0;
const double WIDTH_FIRST_HTTP_LABEL = 188.0;
const double HEIGHT_FIRST_HTTP_LABEL = 21.0;
const double POS_X_FIRST_HTTP_BUTTON = 227.0;
const double POS_Y_FIRST_HTTP_BUTTON = 286.0;
const double WIDTH_FIRST_HTTP_BUTTON = 67.0;
const double HEIGHT_FIRST_HTTP_BUTTON = 30.0;
const double DELTA_Y_HTTP_ELEMENT = 30.0;


@interface ConfigViewController () {
    IBOutlet UILabel *labelRecent;
    
    IPController *ipController;
    NSArray *allIPs;
}

@end



@implementation ConfigViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //NSLog(@"into");
    ipController = [IPController getInstance];
   
    allIPs = [ipController allIPPorts];
    
    textIpPort.text = [(NSString*)allIPs[0] substringFromIndex:7];
    if (allIPs.count == 1) {
        [textIpPort becomeFirstResponder];
        labelRecent.alpha = 0.0;
    }
    else {
        for (int i = 1; i < allIPs.count; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(POS_X_FIRST_HTTP_LABEL, POS_Y_FIRST_HTTP_LABEL + DELTA_Y_HTTP_ELEMENT * (i-1), WIDTH_FIRST_HTTP_LABEL, HEIGHT_FIRST_HTTP_LABEL) ];
            label.textAlignment =  NSTextAlignmentLeft;
            label.textColor = [UIColor blackColor];
            label.backgroundColor = [UIColor clearColor];
            //scoreLabel.font = [UIFont fontWithName:scoreLabel.font.fontName size:(36.0)];
            [self.view addSubview:label];
            label.text = [NSString stringWithFormat: @"%@", allIPs[i]];
            
            UIButton *button = button = [UIButton buttonWithType: UIButtonTypeSystem];
            button.frame = CGRectMake(POS_X_FIRST_HTTP_BUTTON, POS_Y_FIRST_HTTP_BUTTON + DELTA_Y_HTTP_ELEMENT * (i-1), WIDTH_FIRST_HTTP_BUTTON, HEIGHT_FIRST_HTTP_BUTTON);
            [self.view addSubview:button];
            [button setTitle:@"Hold it" forState:UIControlStateNormal];
            button.userInteractionEnabled = YES;
            button.opaque = YES;
            //button.backgroundColor = [UIColor redColor];
            [button addTarget:self
                       action:@selector(buttonTakeIPTouchDown:)
             forControlEvents:UIControlEventTouchDown];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}


#pragma mark - Navigation

- (IBAction)buttonIpConfirmTouchDown:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        //NSLog(@"All okay.");
        [ipController commitIPPort:[[NSString alloc] initWithFormat:@"http://%@", textIpPort.text] ];
        [self.view endEditing:YES];
        [delegate signalReloadIP];
    }];
}

- (IBAction)buttonTakeIPTouchDown:(id)sender {
    UIButton *button = (UIButton*)sender;
    int ind = (button.frame.origin.y - POS_Y_FIRST_HTTP_BUTTON) / DELTA_Y_HTTP_ELEMENT + 1;
    //NSLog(@"hold it %@", allIPs[ind]);
    textIpPort.text = [(NSString*)allIPs[ind] substringFromIndex:7];
}

#pragma mark - Keyboard handler

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
