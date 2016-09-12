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
    [self authenticateUser];
}

//-(void)viewWillAppear:(BOOL)animated{
//    
//}

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
                                      UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error"
                                                                
                                                                                         message:error.localizedDescription
                                                                
                                                                                        delegate:self
                                                                
                                                                               cancelButtonTitle:@"OK"
                                                                
                                                                               otherButtonTitles:nil, nil];
                                      
                                      [alertView show];
                                      NSLog(@"Switch to fall back authentication - ie, display a keypad or password entry box");
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

//-(void) showPasswordAlert{
//    UIAlertView *passwordAlert = [[UIAlertView alloc]initWithTitle:<#(nullable NSString *)#> message:<#(nullable NSString *)#> delegate:<#(nullable id)#> cancelButtonTitle:<#(nullable NSString *)#> otherButtonTitles:<#(nullable NSString *), ...#>, nil
//}

@end
