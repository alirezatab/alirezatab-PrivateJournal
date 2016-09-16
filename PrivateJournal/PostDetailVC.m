//
//  PostDetailVC.m
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 7/8/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import "PostDetailVC.h"
#import "Picture.h"
#import "CoreDataManager.h"

@interface PostDetailVC () <UINavigationControllerDelegate, UIScrollViewDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *singleSelectedImageView;
@property (weak, nonatomic) IBOutlet UILabel *singleSelectedImageLocationLabel;
@property (weak, nonatomic) IBOutlet UITextView *singleSelectedCommentTextView;
@property (weak, nonatomic) IBOutlet UILabel *signleSelectedImagePostedAgo;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property CGFloat keyboardHeight;

@property BOOL isTapped;

@end

@implementation PostDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // initial setup of the view
    self.navigationItem.rightBarButtonItem.title = @"DELETE";
    self.textView.delegate = self;
    self.isTapped = YES;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 6.0;
    
    self.navigationController.toolbarHidden = YES;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    [self loadPicture];
    [self createGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    self.navigationController.toolbarHidden = NO;
    self.navigationController.navigationBar.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)loadPicture{
    Picture *detailPicture = self.detailPictureObject;
    self.singleSelectedImageView.image = [UIImage imageWithData:detailPicture.image];
    self.singleSelectedImageLocationLabel.text = self.detailPictureObject.location;

    self.singleSelectedCommentTextView.text = [NSString stringWithFormat:detailPicture.comment];
}

#pragma mark - Gesture
-(void)createGesture{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
    
    singleTap.numberOfTapsRequired = 1;
    doubleTap.numberOfTapsRequired = 2;
    
    // stops tapOnce from overriding tapTwice
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [self.view addGestureRecognizer:singleTap];
    [self.view addGestureRecognizer:doubleTap];
}

-(void)handleSingleTap:(UITapGestureRecognizer *)recognizer{
    if (self.isTapped) {
        self.navigationController.navigationBar.hidden = YES;
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        self.isTapped = NO;
    } else{
        self.navigationController.navigationBar.hidden = NO;
//        self.navigationController.toolbarHidden = NO;
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        self.isTapped = YES;
    }
}

-(void)handleDoubleTap:(UITapGestureRecognizer *)recognizer{
    
    float newScale = [self.scrollView zoomScale] * 4.0;
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else{
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[recognizer locationInView:recognizer.view]];
        
        [self.scrollView zoomToRect:zoomRect animated:YES];
    }
}

#pragma mark - keyboard
- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
    //CGRect keyboardInfoFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
    CGFloat deltaHeight = keyboardSize.height - _keyboardHeight;
    
    //write code to adjust views accordingly using deltaHeight
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationBeginsFromCurrentState:TRUE];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - deltaHeight, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
    _keyboardHeight = keyboardSize.height;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationBeginsFromCurrentState:TRUE];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + _keyboardHeight, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
    _keyboardHeight = 0.0f;
}

#pragma mark - TextView editing
-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [self.textView resignFirstResponder];
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    Picture *detailPicture = self.detailPictureObject;
    
    // edit all comments
    //NSArray *editedComments = [detailPicture.comment allObjects];
    //for (Comment *comment in editedComments) {
    detailPicture.comment = self.singleSelectedCommentTextView.text;
    //[CoreDataManager editObject:detailPicture];
    //}
    
    // edit comment of a picture
    [CoreDataManager editObject:detailPicture];
    
    [CoreDataManager save];
}

#pragma mark - ZoomScale
-(CGRect) zoomRectForScale:(float)scale withCenter:(CGPoint)center{
    CGRect zoomRect;

    zoomRect.size.height = [self.singleSelectedImageView frame].size.height / scale;
    zoomRect.size.width = [self.singleSelectedImageView frame].size.width / scale;
    
    center = [self.singleSelectedImageView convertPoint:center fromView:self];
    
    zoomRect.origin.x = center.x - ((zoomRect.size.width)/2.0);
    zoomRect.origin.y = center.y - ((zoomRect.size.height)/2.0);
    
    return zoomRect;
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.singleSelectedImageView;
}

#pragma mark - ButtonsPressed
- (IBAction)onEditButtonPressed:(id)sender {
    if (self.editing) {
        self.editing = NO;
        [self.textView setEditable:NO];
        //self.navigationItem.rightBarButtonItem.title = @"Edit";
    } else {
        self.editing = YES;
        [self.textView setEditable:YES];
        [self.textView becomeFirstResponder];
        //self.navigationItem.rightBarButtonItem.title = @"Done";
    }
}

- (IBAction)onDeleteButtonPressed:(UIBarButtonItem *)sender {
        UIAlertView *deleteAlert = [[UIAlertView alloc]initWithTitle:@"Delete??" message:@"Are you sure you want to delete this image permanantly?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        [deleteAlert show];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        Picture *deletedPicture = self.detailPictureObject;
        
        // delete all comments
//        NSArray *deletedComments = [deletedPicture.comments allObjects];
//        for (Comment *comment in deletedComments) {
//            [CoreDataManager deleteObject:comment];
//        }
        
        // delete picture
        [CoreDataManager deleteObject:deletedPicture];
        
        [CoreDataManager save];
        UINavigationController *navController = self.navigationController;
        //Pop this controller and replace with another
        [navController popViewControllerAnimated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
