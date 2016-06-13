//
//  HomeVC.m
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 6/12/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import "HomeVC.h"

@interface HomeVC () <UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property UISearchController *searchController;
@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureSearchController];
}


#pragma mark- CollectionView
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 10;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    return imageCell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //later NSLog the index path that were selected
}

#pragma mark- Actions
- (IBAction)onAddPhotoButtonPressed:(UIBarButtonItem *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)onShareButtonPressed:(UIBarButtonItem *)sender {
}

- (IBAction)onCameraButtonPressed:(UIBarButtonItem *)sender {
    [self turnCameraOn];
    
}

#pragma mark- Camera
-(void)turnCameraOn {
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraCaptureMode = UIImagePickerControllerCameraDeviceRear;
    //  show navagation bar so we can put an x to cancel
    picker.navigationBarHidden = NO;
    //  have a toolbar show up in the below so we can add additional buttons
    picker.toolbarHidden = YES;
    //  picker.wantsFullScreenLayout = YES;
    picker.delegate = self;
    //  crop boz arund the image after its taken
    picker.allowsEditing = NO;
    //  make all the camera controls appear or disappear
    picker.showsCameraControls = YES;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

// when cancel button of the camera is selected
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector((_cmd)));
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark- search Controller
- (void)configureSearchController {
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    
    //self.searchController.searchResultsUpdater = self;
   // self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    
    self.searchController.hidesNavigationBarDuringPresentation = false;
    self.searchController.dimsBackgroundDuringPresentation = true;
    
    self.navigationItem.titleView = self.searchController.searchBar;
    
    self.searchController.searchBar.placeholder = @"Search Images";
    //[self.searchController.searchBar sizeToFit];
    self.definesPresentationContext = true;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
