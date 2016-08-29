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


@interface PostImageVC () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *toBePostedImageView;
@property (weak, nonatomic) IBOutlet UITextView *userCommentTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postBarButtonItem;
@property (weak, nonatomic) IBOutlet UITableViewCell *addLocationCell;
@end


@implementation PostImageVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.toBePostedImageView.image = self.snappedImage;

    self.userCommentTextView.text = @"Write a caption...";
    self.userCommentTextView.textColor = [UIColor lightGrayColor];
    self.userCommentTextView.delegate = self;
    
    self.postBarButtonItem.enabled = NO;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    NSLog(@"??? %@", self.passedSelectedLocation.mapItem.name);
    NSLog(@"%@", self.addLocationCell.textLabel.text);
    
    if ([self.passedSelectedLocation.mapItem isKindOfClass:[MKMapItem class]]) {
        self.addLocationCell.textLabel.text = self.passedSelectedLocation.mapItem.name;
    } else {
        self.addLocationCell.textLabel.text = @"Add Location";
    }
}

#pragma mark - textView editing
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if ([self.userCommentTextView.text containsString:@"Write a caption..."]) {
        self.userCommentTextView.text = @"";
        self.userCommentTextView.textColor = [UIColor blackColor];
        //self.okButton.hidden = NO;
        self.postBarButtonItem.enabled = YES;
    } else {
        [self.userCommentTextView.text stringByAppendingString:self.userCommentTextView.text];
    }
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView{
    if (self.userCommentTextView.text.length == 0) {
        self.userCommentTextView.textColor = [UIColor lightGrayColor];
        self.userCommentTextView.text = @"Write a caption...";
        [self.userCommentTextView resignFirstResponder];
        self.postBarButtonItem.enabled = NO;
    }
}

# pragma mark - buttonsPressed
- (IBAction)onPostButtonPressed:(UIBarButtonItem *)sender {
    [CoreDataManager addPicture:self.toBePostedImageView.image withComment:self.userCommentTextView.text withLocation:self.passedSelectedLocation.mapItem.name fromUser:[self getMyUser]];
    
    [CoreDataManager save];
    UINavigationController *navController = self.navigationController;
    //Pop this controller and replace with another
    [navController popViewControllerAnimated:NO];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

// getMyUser() - returns User object for current user
// TODO: this should come from parent VC instead (?)
-(User *)getMyUser {
    return [CoreDataManager getUserZero];
}

- (IBAction)unwindFromModalAddLocationViewController:(UIStoryboardSegue *)segue{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
