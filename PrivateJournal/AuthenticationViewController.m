//
//  AuthenticationViewController.m
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 9/11/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import "AuthenticationViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>


@implementation AuthenticationViewController{
    BOOL wasLogoTapped;
}
-(void)viewDidLoad{
    [super viewDidLoad];
    wasLogoTapped = NO;
    
    [NSTimer scheduledTimerWithTimeInterval:4.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
        if (!wasLogoTapped) {
            [self authenticateUser];
        }
    }];
}

- (IBAction)onAuthenticationLogoPressed:(UIButton *)sender {
    wasLogoTapped = YES;
    [self authenticateUser];
}

-(void) authenticateUser{
    LAContext *context = [[LAContext alloc]init];
    NSError *authError = nil;
    NSString *myLocalizedReasonString = @"Authentication is needed to access Private Picture Journal";
    
    // If true: device supports TouchID authentication, TouchID is enabled in device Setting. one finger at least has been enrolled
    //Passcode is SET, and of course.
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        [context evaluatePolicy:
         LAPolicyDeviceOwnerAuthentication
                localizedReason:myLocalizedReasonString
                          reply:^(BOOL success, NSError *error) {
                              if (success) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [self performSegueWithIdentifier:@"Success" sender:nil];
                                  });
                              } else {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      
                                      switch (error.code) {
                                          case LAErrorAuthenticationFailed:
                                              NSLog(@"Authentication was not successful because the user failed to provide valid credentials.");
                                              break;
                                          case LAErrorUserCancel:
                                              NSLog(@"Authentication was canceled by the user—for example, the user tapped Cancel in the dialog.");
                                              break;
                                          case LAErrorUserFallback:
                                              NSLog(@"Authentication was canceled because the user tapped the fallback button (Enter Password).");
                                              break;
                                          case LAErrorSystemCancel:
                                              NSLog(@"Authentication was canceled by system—for example, if another application came to foreground while the authentication dialog was up.");
                                              break;
                                          case LAErrorPasscodeNotSet:
                                              NSLog(@"Authentication could not start because the passcode is not set on the device.");
                                              break;
                                          case LAErrorTouchIDNotAvailable:
                                              NSLog(@"Authentication could not start because Touch ID is not available on the device.");
                                              break;
                                          case LAErrorTouchIDNotEnrolled    :
                                              NSLog(@"Authentication could not start because Touch ID has no enrolled fingers.");
                                              break;
                                              
                                          default:
                                              break;
                                      }
                                  });
                              }
                          }];
    } else {
        [self touchIdIsNotConfigured];
    }
}

-(void)touchIdIsNotConfigured{
    UIAlertController *settingAlert = [UIAlertController alertControllerWithTitle:@"Touch ID is not configured"
                                                                          message:@"Please configure your TouchID & Passcode so your PrivateJournal Stays PTIVATe"
                                                                   preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                 }];
    [settingAlert addAction:ok];
    [self presentViewController:settingAlert animated:YES completion:nil];
    
    [self performSegueWithIdentifier:@"HomeVC" sender:self];

}

@end
