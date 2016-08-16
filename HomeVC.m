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

@property UIImage *originalCameraImage;
@property UIImage *CameraImageCorrectedOriantation;
@property UIImage *originalLibraryImage;
@property UIImage *libraryImageCorrectedOrientation;
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
        return self.filteredArrayOfPosts.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ImageCollectionViewCell *imageCollectionCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    
    id picOrComment;
        if ([self.filteredArrayOfPosts[indexPath.row] isKindOfClass:[Picture class]]) {
            picOrComment = self.filteredArrayOfPosts[indexPath.row];
        } else {
            picOrComment = self.filteredArrayOfPosts[indexPath.row];
        }
    
    if ([picOrComment isKindOfClass:[Picture class]]) {
        Picture *pic = picOrComment;
        imageCollectionCell.imageView.image = [UIImage imageWithData:pic.image];
    } else {
        Comment *pictureFromComment = picOrComment;
        Picture *pic = pictureFromComment.picture;
        imageCollectionCell.imageView.image = [UIImage imageWithData:pic.image];
    }

    collectionView.backgroundColor = [UIColor blackColor];
    
    return imageCollectionCell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));
    NSLog(@"Section: %ld, row:%ld", (long)indexPath.section, (long)indexPath.row);
    
    Picture *pic = [self.filteredArrayOfPosts objectAtIndex: indexPath.row];
    NSData *imageData = pic.image;
    
    NSUInteger imageSize = imageData.length;
    NSLog(@"size of image in KB: %f", imageSize/1024.0);
    
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
    self.originalCameraImage = info[UIImagePickerControllerOriginalImage];
    //flips the picture to have right oriantation
    self.CameraImageCorrectedOriantation = [self squareImageWithImage:self.originalCameraImage scaledToSize:CGSizeMake(300, 1)];
    //save the tempImage as Jpeg
    self.CameraImageCorrectedOriantation = [UIImage imageWithData:UIImageJPEGRepresentation(self.CameraImageCorrectedOriantation, 1.0)];

    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *photoTaken = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        //save photo to library if it wasn't already saved... just been taken
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(photoTaken, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        } else if ( picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
            self.originalLibraryImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            // if from library, store it as jpeg
            self.originalLibraryImage = [UIImage imageWithData:UIImageJPEGRepresentation(self.originalLibraryImage, 1.0)];
            self.libraryImageCorrectedOrientation = [self squareImageWithImage:self.originalCameraImage scaledToSize:CGSizeMake(600, 600)];

            [self performSegueWithIdentifier:@"LibraryPhoto" sender:self];
        }
    }
    [self performSegueWithIdentifier:@"CameraPictureToPost" sender:self];
    [picker dismissViewControllerAnimated:NO completion: NULL];
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector((_cmd)));
    
    if (!error) {
        //[self performSegueWithIdentifier:@"CameraPictureToPost" sender:self];
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

///new
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"texts entered are %@", searchText);
    
    self.filteredArrayOfPosts = [self filterArray:self.arrayOfPosts with:searchText];
    if ([searchText length] > 0) {
        self.filteredArrayOfPosts = [self.filteredArrayOfPosts sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            Comment *comment1 = obj1;
            Comment *comment2 = obj2;
            return [comment1.text.lowercaseString compare:comment2.text.lowercaseString];
        }];
    }
    [self.collectionView reloadData];
}

-(NSArray *)filterArray:(NSArray *)oldArray with:(NSString *)filterString{
    if ([filterString isEqualToString:@""]) {
        return oldArray;
    }
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    
    NSString *filterStringLower = [filterString lowercaseString];
    for (Picture *picture in oldArray) {
        for (Comment *comment in picture.comments) {
            NSString *elemText = comment.text;
            NSLog(@"%@", elemText);
            NSString *elemTextLower = [elemText lowercaseString];
            if ([elemTextLower containsString:filterStringLower]) {
                [newArray addObject:comment];
            }
        }
    }
    self.shouldShowSearchResults = YES;
    return [NSArray arrayWithArray:newArray];
}
///upto here


#pragma mark - Data
-(void)reloadAllData {
    //self.arrayOfPosts = [self sortPicturesByDate:[self.user.pictures allObjects]];
    self.user = [CoreDataManager fetchUsers];
    for (User *u in self.user) {
        NSLog(@"%@: %lu pics", u.username, u.pictures.count);
        self.arrayOfPosts = [self sortPicturesByDate:[u.pictures allObjects]];
    }
    self.filteredArrayOfPosts = [NSArray arrayWithArray:self.arrayOfPosts];
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
        desVC.snappedImage = self.CameraImageCorrectedOriantation;
    } else if ([segue.identifier isEqualToString:@"LibraryPhoto"]){
        PostImageVC *desVC = segue.destinationViewController;
        desVC.snappedImage = self.libraryImageCorrectedOrientation;
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
