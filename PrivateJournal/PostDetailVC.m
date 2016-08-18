//
//  PostDetailVC.m
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 7/8/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import "PostDetailVC.h"

@interface PostDetailVC () <UINavigationControllerDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *singleSelectedImageView;
@property (weak, nonatomic) IBOutlet UILabel *singleSelectedImageLocationLabel;
@property (weak, nonatomic) IBOutlet UITextView *singleSelectedCommentTextView;
@property (weak, nonatomic) IBOutlet UILabel *signleSelectedImagePostedAgo;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property BOOL isTapped;

@end

@implementation PostDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.toolbarHidden = YES;
    
    self.singleSelectedImageView.image = self.detailPictureObject;
    self.singleSelectedImageLocationLabel.text = self.detailPictureObjectLocation;
    self.singleSelectedCommentTextView.text = self.detailPictureObjectComment;
    self.signleSelectedImagePostedAgo.text = self.detailPictureObjectPostedAgo;
    
    //self.tabBarController.tabBar.hidden = true;
    self.isTapped = YES;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
    
    singleTap.numberOfTapsRequired = 1;
    doubleTap.numberOfTapsRequired = 2;
    
    // stops tapOnce from overriding tapTwice
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [self.view addGestureRecognizer:singleTap];
    [self.view addGestureRecognizer:doubleTap];
    
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 6.0;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    self.navigationController.toolbarHidden = NO;
}

-(CGRect) zoomRectForScale:(float)scale withCenter:(CGPoint)center{
    CGRect zoomRect;

    zoomRect.size.height = [self.singleSelectedImageView frame].size.height / scale;
    zoomRect.size.width = [self.singleSelectedImageView frame].size.width / scale;
    
    center = [self.singleSelectedImageView convertPoint:center fromView:self];
    
    zoomRect.origin.x = center.x - ((zoomRect.size.width)/2.0);
    zoomRect.origin.y = center.y - ((zoomRect.size.height)/2.0);
    
    return zoomRect;
}

-(void)handleSingleTap:(UITapGestureRecognizer *)recognizer{
    if (self.isTapped) {
        self.navigationController.navigationBar.hidden = YES;
//        self.navigationController.toolbarHidden = YES;
        self.isTapped = NO;
    } else{
        self.navigationController.navigationBar.hidden = NO;
//        self.navigationController.toolbarHidden = NO;
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

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.singleSelectedImageView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
