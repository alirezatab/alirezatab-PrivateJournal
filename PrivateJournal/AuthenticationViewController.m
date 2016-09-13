//
//  AuthenticationViewController.m
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 9/11/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import "AuthenticationViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@implementation AuthenticationViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(authenticateUser) userInfo:nil repeats:NO];
}

- (IBAction)onAuthenticationLogoPressed:(UIButton *)sender {
    [self authenticateUser];
}

-(void) authenticateUser{
    LAContext *context = [[LAContext alloc]init];
    NSError *authError = nil;
    NSString *myLocalizedReasonString = @"Authentication is needed to access Private Picture Journal";
    
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        [context evaluatePolicy:
         LAPolicyDeviceOwnerAuthenticationWithBiometrics
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
                                      
//  UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error"                                                                                       message:@"more than 3 attempts have been made"                                                                                       delegate:self                                                                              cancelButtonTitle:@"OK"                                                                              otherButtonTitles:@"Enter Passcode", nil];
                                      
//  [alertView show];
//  NSLog(@"Switch to fall back authentication - ie, display a keypad or password entry box");
                                  });
                              }
                          }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error"
                                      
                                                               message:authError.localizedDescription
                                      
                                                              delegate:self
                                      
                                                     cancelButtonTitle:@"OK"
                                      
                                                     otherButtonTitles:nil, nil];
            [alertView show];
        });
    }
}

@end
