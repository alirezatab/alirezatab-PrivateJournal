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

@interface PostImageVC ()
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *toBePostedImageView;
@property (weak, nonatomic) IBOutlet UITextField *userCommentTextField;
@end

@implementation PostImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backgroundImageView.image = self.snappedImage;
    self.toBePostedImageView.image = self.snappedImage;
}

- (IBAction)onPostButtonPressed:(UIBarButtonItem *)sender {
    [CoreDataManager addPicture:self.toBePostedImageView.image withComment:self.userCommentTextField.text fromUser:[self getMyUser]];
    [CoreDataManager save];
    
    UINavigationController *navController = self.navigationController;
    //Pop this controller and replace with another
    [navController popViewControllerAnimated:NO];
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
