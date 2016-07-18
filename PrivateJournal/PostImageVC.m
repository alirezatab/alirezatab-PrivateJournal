//
//  PostImageVC.m
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 6/29/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import "PostImageVC.h"
#import "CoreDataManager.h"
#import "Picture.h"
#import "Hashtag.h"
//#import "PIcAndCommentTableViewCell.h"


@interface PostImageVC () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *toBePostedImageView;
@property (weak, nonatomic) IBOutlet UITextView *userCommentTextView;

@end

@implementation PostImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.toBePostedImageView.image = self.snappedImage;
    
}

- (IBAction)onPostButtonPressed:(UIBarButtonItem *)sender {

    [CoreDataManager addPicture:self.toBePostedImageView.image withComment:self.userCommentTextView.text fromUser:[self getMyUser]];
    [CoreDataManager save];
    
    UINavigationController *navController = self.navigationController;
    //Pop this controller and replace with another
    [navController popViewControllerAnimated:NO];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

// getMyUser() - returns User object for current user
// TODO: this should come from parent VC instead (?)
-(User *)getMyUser {
    return [CoreDataManager getUserZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
