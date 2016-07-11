//
//  PostDetailVC.m
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 7/8/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import "PostDetailVC.h"

@interface PostDetailVC ()
@property (weak, nonatomic) IBOutlet UIImageView *singleSelectedImageView;

@end

@implementation PostDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.singleSelectedImageView.image = self.detailPictureObject.image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
