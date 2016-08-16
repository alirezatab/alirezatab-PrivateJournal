//
//  PostDetailVC.m
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 7/8/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import "PostDetailVC.h"

@interface PostDetailVC () <UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *singleSelectedImageView;
@property (weak, nonatomic) IBOutlet UILabel *singleSelectedImageLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *singleSelectedCommentLabel;
@property (weak, nonatomic) IBOutlet UILabel *signleSelectedImagePostedAgo;

@property BOOL isTapped;

@end

@implementation PostDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.singleSelectedImageView.image = self.detailPictureObject;
    self.singleSelectedImageLocationLabel.text = self.detailPictureObjectLocation;
    self.singleSelectedCommentLabel.text = self.detailPictureObjectComment;
    self.signleSelectedImagePostedAgo.text = self.detailPictureObjectPostedAgo;
    
    self.tabBarController.tabBar.hidden = true;
    self.isTapped = YES;
}

//-(IBAction)handlePan:(UIPanGestureRecognizer *) recognizer {
//    CGPoint translation = [recognizer translationInView:self.view];
//    recognizer.view.center = CGPointMake(recognizer.view.center.x +translation.x, recognizer.view.center.y + translation.y);
//    
//    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
//}
//
//-(IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer {
//    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
//    if (recognizer.state == UIGestureRecognizerStateBegan ||
//        recognizer.state == UIGestureRecognizerStateChanged) {
//        CGFloat scale = recognizer.scale;
//        
//        [recognizer.view setTransform:CGAffineTransformScale(recognizer.view.transform, scale, scale)];
//        
//        [recognizer setScale:1.0];
//    }
//}

-(IBAction)handleSingleTap:(UITapGestureRecognizer *)recognizer{
    if (self.isTapped) {
        self.navigationController.navigationBar.hidden = YES;
        self.navigationController.toolbarHidden = YES;
        self.isTapped = NO;
    } else{
        self.navigationController.navigationBar.hidden = NO;
        self.navigationController.toolbarHidden = NO;
        self.isTapped = YES;
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
