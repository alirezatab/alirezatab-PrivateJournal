//
//  HomeVC.m
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 6/12/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>

#import "HomeVC.h"
#import "CustomImageFlowLayout.h"
#import "ImageCollectionViewCell.h"
#import "PostImageVC.h"
#import "AppDelegate.h"
#import "Picture.h"
#import "CoreDataManager.h"
#import "User.h"
#import "User.h"
#import "PostDetailVC.h"
#import "Comment.h"

//#import <MobileCoreServices/MobileCoreServices.h>
//#import <Photos/Photos.h>

@interface HomeVC () <UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchBarDelegate>
@property(weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property(nonatomic, strong) PHFetchResult *assetsFetchResults;
@property(nonatomic, strong) PHCachingImageManager *imageManager;

@property NSMutableArray *collector;

@property UIImage *snappedCameraImage;
@property UIImage *snappedCameraImageFlipped;
@property UIImage *PhotosLibraryImage;
@property UIImage *detailPostImage;
@property NSString *detailPostLocation;
@property NSString *detailPostComment;
@property NSString *detailPostAgo;

@property UISearchController *searchController;

@property BOOL shouldShowSearchResults;
@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // SQLite
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSLog(@"sqlite dir = \n%@", appDelegate.applicationDocumentsDirectory);
    
    [self configureSearchController];
    
    self.collectionView.collectionViewLayout = [[CustomImageFlowLayout alloc] init];
    self.collectionView.backgroundColor = [UIColor whiteColor];

    //when true, the filteredArrayOfPosts will be used
    self.shouldShowSearchResults = NO;
    
    //search results
    self.arrayOfPosts = [[NSArray alloc]init];
    self.filteredArrayOfPosts = [[NSArray alloc]init];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadAllData];
}

#pragma mark- CollectionView
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.shouldShowSearchResults) {
        return self.filteredArrayOfPosts.count;
    } else {
        return self.arrayOfPosts.count;
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ImageCollectionViewCell *imageCollectionCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    
    Picture *pic;
    if (self.shouldShowSearchResults) {
        pic = self.filteredArrayOfPosts[indexPath.row];
    } else {
        pic = self.arrayOfPosts[indexPath.row];
    }
    
    imageCollectionCell.imageView.image = [UIImage imageWithData:pic.image];
    collectionView.backgroundColor = [UIColor blackColor];
    
    return imageCollectionCell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));
    NSLog(@"Section: %ld, row:%ld", (long)indexPath.section, (long)indexPath.row);
    
    Picture *pic = [self.arrayOfPosts objectAtIndex: indexPath.row];
    NSData *imageData = pic.image;
    
    self.detailPostImage = [UIImage imageWithData:imageData];
    self.detailPostLocation = pic.location;
    NSArray *comments = [pic.comments allObjects];
    Comment *comment = comments[0];
    NSLog(@"the commetn is: %@", comment.text);
    self.detailPostComment = comment.text;
    self.detailPostAgo = comment.agoString;
    
    [self performSegueWithIdentifier:@"aPictureSelected" sender:nil];
}

#pragma mark- Actions
- (IBAction)onAddPhotoButtonPressed:(UIBarButtonItem *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)onShareButtonPressed:(UIBarButtonItem *)sender {
    /// unlock when app sharing portion is figred out
    [self displayShareSheet];
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

#pragma mark - Camera delegates
// fired when we take picture
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector((_cmd)));

    NSString *mediaType = info[UIImagePickerControllerMediaType];
    //retrieve the actual UIImage when the picture is captures
    self.snappedCameraImageFlipped = info[UIImagePickerControllerOriginalImage];
    //flips the picture to have right oriantation
    self.snappedCameraImage = [self squareImageWithImage:self.snappedCameraImageFlipped scaledToSize:CGSizeMake(200, 200)];

    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *photoTaken = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        //save photo to library if it wasn't already saved... just been taken
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(photoTaken, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        } else if ( picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
            self.PhotosLibraryImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            [self performSegueWithIdentifier:@"LibraryPhoto" sender:self];
        }
    }
    [picker dismissViewControllerAnimated:YES completion: NULL];
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector((_cmd)));
    
    if (!error) {
        [self performSegueWithIdentifier:@"CameraPictureToPost" sender:self];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                       message:[error localizedDescription]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action){}];
        
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

// when cancel button of the camera is selected
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector((_cmd)));
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - fixing orientation of photo and scale
- (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    double ratio;
    double delta;
    CGPoint offset;
    
    //make a new square size, that is the resized imaged width
    CGSize sz = CGSizeMake(newSize.width, newSize.width);
    
    //figure out if the picture is landscape or portrait, then
    //calculate scale factor and offset
    if (image.size.width > image.size.height) {
        ratio = newSize.width / image.size.width;
        delta = (ratio*image.size.width - ratio*image.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = newSize.width / image.size.height;
        delta = (ratio*image.size.height - ratio*image.size.width);
        offset = CGPointMake(0, delta/2);
    }
    
    //make the final clipping rect based on the calculated values
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * image.size.width) + delta,
                                 (ratio * image.size.height) + delta);
    
    //start a new context, with scale factor 0.0 so retina displays get
    //high quality image
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark- search Controller
- (void)configureSearchController {
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    
    // self.searchController.searchResultsUpdater = self;
    // self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    
    self.searchController.hidesNavigationBarDuringPresentation = false;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    
    self.navigationItem.titleView = self.searchController.searchBar;
    
    self.searchController.searchBar.placeholder = @"Search Images";
    //[self.searchController.searchBar sizeToFit];
    self.definesPresentationContext = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    self.shouldShowSearchResults = YES;
    [self.collectionView reloadData];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.shouldShowSearchResults = NO;
    //[self.collectionView reloadData];
    ///maybe reload data is not needed here
    [self.collectionView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (!self.shouldShowSearchResults) {
        self.shouldShowSearchResults = YES;
        [self.collectionView reloadData];
    }
    [self.searchController.searchBar resignFirstResponder];
}

/// To DO- find the right pictures when text is entered in the search bar
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    //NSString *searchString = searchController.searchBar.text;
    
    /// Filter the data array and get only those pictures that match the search text
   // self.filteredArrayOfPosts =
}

#pragma mark - Data
-(void)reloadAllData {
    //self.arrayOfPosts = [self sortPicturesByDate:[self.user.pictures allObjects]];
    self.user = [CoreDataManager fetchUsers];
    for (User *u in self.user) {
        NSLog(@"%@: %lu pics", u.username, u.pictures.count);
        self.arrayOfPosts = [self sortPicturesByDate:[u.pictures allObjects]];
    }
    [self.collectionView reloadData];
}

-(NSArray *)sortPicturesByDate:(NSArray *)oldArray {
    return [oldArray sortedArrayUsingComparator:
            ^NSComparisonResult(Picture *p1, Picture *p2) {
                return [p2.time compare:p1.time];
            }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"CameraPictureToPost"]) {
        PostImageVC *desVC = segue.destinationViewController;
        desVC.snappedImage = self.snappedCameraImage;
    } else if ([segue.identifier isEqualToString:@"LibraryPhoto"]){
        PostImageVC *desVC = segue.destinationViewController;
        desVC.snappedImage = self.PhotosLibraryImage;
    } else if ([segue.identifier isEqualToString:@"aPictureSelected"]){
        
        PostDetailVC *destVC = segue.destinationViewController;
        
        destVC.detailPictureObject = self.detailPostImage;
        destVC.detailPictureObjectLocation = self.detailPostLocation;
        destVC.detailPictureObjectComment = self.detailPostComment;
        destVC.detailPictureObjectPostedAgo = self.detailPostAgo;
    }
}

///TO DO: share app with friends
-(void)displayShareSheet{
    NSArray *shareContent = [[NSArray alloc]initWithObjects:@"Download Private Journal and keep track of your shitty life", nil];
    
    UIActivityViewController *shareSheet = [[UIActivityViewController alloc]initWithActivityItems:shareContent applicationActivities:nil];
    
    [self presentViewController:shareSheet animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
