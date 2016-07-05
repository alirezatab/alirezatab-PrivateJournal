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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
