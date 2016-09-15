//
//  HomeVC.m
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 6/12/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>

#import "ImageCollectionViewCell.h"
#import "CustomImageFlowLayout.h"
#import "CoreDataManager.h"
#import "PostDetailVC.h"
#import "PostImageVC.h"
#import "AppDelegate.h"
#import "Picture.h"
#import "Comment.h"
#import "HomeVC.h"
#import "User.h"
#import "User.h"

@interface HomeVC () <UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchBarDelegate/*, NSFetchedResultsControllerDelegate*/>
    @property(weak, nonatomic) IBOutlet UICollectionView *collectionView;
    //@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
    @property UISearchController *searchController;
    @property NSBlockOperation *blockOperation;
    @property NSMutableArray *collector;
    @property UIImage *originalLibraryImage;
    @property UIImage *snappedImage;
    @property Picture *picture;
    @property BOOL shouldReloadCollectionView;
    @property BOOL shouldShowSearchResults;
    @property int itemToBeDeleted;

//@property NSManagedObjectContext *moc;

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
    //self.moc = appDelegate.managedObjectContext;

    
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
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
//    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
//    return [sectionInfo numberOfObjects];
    return self.filteredArrayOfPosts.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    
    id picOrComment;
    if ([self.filteredArrayOfPosts[indexPath.row] isKindOfClass:[Picture class]]) {
        //picOrComment = [self.fetchedResultsController objectAtIndexPath:indexPath];
        picOrComment = self.filteredArrayOfPosts[indexPath.row];
    } else {
        //picOrComment = [self.fetchedResultsController objectAtIndexPath:indexPath];
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
    picker.navigationBarHidden = NO;
    picker.toolbarHidden = YES;
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.showsCameraControls = YES;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

#pragma mark - Camera delegates
// fired when we take picture
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    image = [self squareImageWithImage:image scaledToSize:CGSizeMake(300, 1)];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *photoTaken = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            self.snappedImage = image;
            UIImageWriteToSavedPhotosAlbum(photoTaken, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            [self performSegueWithIdentifier:@"CameraPictureToPost" sender:self];
            
        } else if ( picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
            
            self.originalLibraryImage = image;
            
            [self performSegueWithIdentifier:@"LibraryPhoto" sender:self];
        }
    }

    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    if (!error) {
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
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.shouldShowSearchResults = NO;
    [self reloadAllData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (!self.shouldShowSearchResults) {
        self.shouldShowSearchResults = YES;
        [self.collectionView reloadData];
    }
    [self.searchController.searchBar resignFirstResponder];
}

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

#pragma mark - Data
-(void)reloadAllData {
    self.user = [CoreDataManager getUserZero];
    self.arrayOfPosts = [self sortPicturesByDate:[self.user.pictures allObjects]];
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
        desVC.snappedImage = self.snappedImage;
    } else if ([segue.identifier isEqualToString:@"LibraryPhoto"]){
        PostImageVC *desVC = segue.destinationViewController;
        desVC.snappedImage = self.originalLibraryImage;
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

#pragma mark - Sign Out
- (IBAction)signOutButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//#pragma mark - New
//delegate method
//-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
//    self.shouldReloadCollectionView = NO;
//    self.blockOperation = [[NSBlockOperation alloc]init];
//}
//
////this performs the animation
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
//    
//    __weak UICollectionView *collectionView = self.collectionView;
//    
//    switch (type) {
//        case NSFetchedResultsChangeInsert: {
//            if ([collectionView numberOfSections] > 0) {
//                if ([collectionView numberOfItemsInSection:indexPath.section] == 0) {
//                    self.shouldReloadCollectionView = YES;
//                } else {
//                    [self.blockOperation addExecutionBlock:^{
//                        [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
//                    }];
//                }
//            } else {
//                self.shouldReloadCollectionView = YES;
//            }
//            break;
//        }
//        case NSFetchedResultsChangeDelete: {
//            if ([collectionView numberOfItemsInSection:indexPath.section] == 1) {
//                self.shouldReloadCollectionView = YES;
//            } else {
//                [self.blockOperation addExecutionBlock:^{
//                    [collectionView deleteItemsAtIndexPaths:@[indexPath]];
//                }];
//            }
//            break;
//        }
//            
//        case NSFetchedResultsChangeUpdate: {
//            [self.blockOperation addExecutionBlock:^{
//                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
//            }];
//            break;
//        }
//        default:
//            break;
//    }
//}
//
//////step 8
//////delegate method
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    if (self.shouldReloadCollectionView) {
//        [self.collectionView reloadData];
//    } else {
//        [self.collectionView performBatchUpdates:^{
//            [self.blockOperation start];
//        } completion:nil];
//    }
//}
//
////step 2
//- (NSFetchRequest *)entrylistfetchRequest {
//    
//    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Comment"];
//    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO]];
//    return  fetchRequest;
//}
//
//- (NSFetchedResultsController*)fetchedResultsController {
//    if (_fetchedResultsController != nil) {
//        return _fetchedResultsController;
//    }
//    
//    NSFetchRequest *fetchRequest = [self entrylistfetchRequest];
//    
//    _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.moc sectionNameKeyPath:nil cacheName:nil];
//    _fetchedResultsController.delegate = self;
//    return _fetchedResultsController;
//}

@end