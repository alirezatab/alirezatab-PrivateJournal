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
@property UISearchController *searchController;
@property UIImage *originalCameraImage;
@property UIImage *CameraImageCorrectedOriantation;
@property UIImage *originalLibraryImage;
@property UIImage *libraryImageCorrectedOrientation;
@property Picture *picture;
@property int itemToBeDeleted;
@property BOOL shouldShowSearchResults;
@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView setAlpha:0.0];
    
    self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
    self.navigationController.toolbar.barTintColor = [UIColor darkGrayColor];
    
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
    if (self.filteredArrayOfPosts.count == 0) {
        [self.collectionView setAlpha:0.0];
    } else {
        [self.collectionView setAlpha:1.0];
    }
}

#pragma mark- CollectionView
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
        return self.filteredArrayOfPosts.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    
    id picOrComment;
    if ([self.filteredArrayOfPosts[indexPath.row] isKindOfClass:[Picture class]]) {
        picOrComment = self.filteredArrayOfPosts[indexPath.row];
    } else {
        picOrComment = self.filteredArrayOfPosts[indexPath.row];
    }
    
    if ([picOrComment isKindOfClass:[Picture class]]) {
        self.picture = picOrComment;
        cell.imageView.image = [UIImage imageWithData:self.picture.image];
    } else {
        Comment *pictureFromComment = picOrComment;
        self.picture = pictureFromComment.picture;
        cell.imageView.image = [UIImage imageWithData:self.picture.image];
    }
    
    collectionView.backgroundColor = [UIColor blackColor];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    id picOrComment;
    if ([self.filteredArrayOfPosts[indexPath.row] isKindOfClass:[Picture class]]) {
        picOrComment = self.filteredArrayOfPosts[indexPath.row];
    } else {
        picOrComment = self.filteredArrayOfPosts[indexPath.row];
    }
    
    if ([picOrComment isKindOfClass:[Picture class]]) {
        self.picture = picOrComment;
    } else {
        Comment *pictureFromComment = picOrComment;
        self.picture = pictureFromComment.picture;
    }
    
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
            [self performSegueWithIdentifier:@"CameraPictureToPost" sender:self];

        } else if ( picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
            self.originalLibraryImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            // if from library, store it as jpeg
            self.originalLibraryImage = [UIImage imageWithData:UIImageJPEGRepresentation(self.originalLibraryImage, 1.0)];
            self.libraryImageCorrectedOrientation = [self squareImageWithImage:self.originalCameraImage scaledToSize:CGSizeMake(600, 600)];

            [self performSegueWithIdentifier:@"LibraryPhoto" sender:self];
        }
    }
    [picker dismissViewControllerAnimated:NO completion: NULL];
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
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
    //NSLog(@"[%@ %@]", self.class, NSStringFromSelector((_cmd)));
    
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
    
    UITextField *textFieldSearchField = [self.searchController.searchBar valueForKey:@"_searchField"];
    
    textFieldSearchField.backgroundColor = [UIColor lightGrayColor];
    textFieldSearchField.textColor = [UIColor blackColor];
    textFieldSearchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search for Images" attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    
    self.searchController.searchBar.delegate = self;
    self.searchController.hidesNavigationBarDuringPresentation = false;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    
    self.navigationItem.titleView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    // self.searchController.searchResultsUpdater = self;
    // self.searchController.delegate = self;
    //self.searchController.searchBar.placeholder = @"Search Images";
    //[self.searchController.searchBar sizeToFit];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.shouldShowSearchResults = NO;
    //[self.collectionView reloadData];
    ///maybe reload data is not needed here
    [self reloadAllData];
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
    self.user = [CoreDataManager fetchUsers];
    for (User *u in self.user) {
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
        destVC.detailPictureObject = self.picture;
        destVC.me = self.user;
    }
}

#pragma mark - gestures
-(IBAction)handleLongPressToDelete:(UILongPressGestureRecognizer *)recognizer{
    CGPoint tapLocation = [recognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:tapLocation];
    if (indexPath && recognizer.state == UIGestureRecognizerStateBegan) {
        self.itemToBeDeleted = (int)indexPath.item;
        
        UIAlertView *deleteAlert = [[UIAlertView alloc]initWithTitle:@"Delete??" message:@"Are you sure you want to delete this image permanantly?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        [deleteAlert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        Picture *deletedPicture = self.filteredArrayOfPosts[self.itemToBeDeleted];
        
        // delete all comments
        NSArray *deletedComments = [deletedPicture.comments allObjects];
        for (Comment *comment in deletedComments) {
            [CoreDataManager deleteObject:comment];
        }
        
        // delete picture
        [CoreDataManager deleteObject:deletedPicture];
        
        [CoreDataManager save];
        [self reloadAllData];
    }
}

#pragma mark - Share App
-(void)displayShareSheet{
    NSArray *shareContent = [[NSArray alloc]initWithObjects:@"Your friend is recommanding you to download and use Private Journal", nil];
    
    UIActivityViewController *shareSheet = [[UIActivityViewController alloc]initWithActivityItems:shareContent applicationActivities:nil];
    
    [self presentViewController:shareSheet animated:YES completion:nil];
}

- (IBAction)signOutButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
