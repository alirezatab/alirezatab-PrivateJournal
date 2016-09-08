//
//  AddLocationVC.m
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 7/19/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import "AddLocationVC.h"
#import "NearbyLocation.h"
#import "PostImageVC.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface AddLocationVC () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property UISearchController *searchController;

@property CLLocationManager *locationManager;
@property MKLocalSearch *localSreach;
@property MKLocalSearchResponse *result;

@property NSMutableArray *arrayOfNearbyLocations;
//@property NSMutableArray *arrayOfSearchedLocations;
@property MKCoordinateRegion *currentLocation;
@property NSString *searchTerm;
@property BOOL shouldShowSearchResults;
@end

@implementation AddLocationVC

- (void)viewDidLoad {
    [super viewDidLoad];

    // setup delegate and dataSource
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // initilize the arrays
    //self.arrayOfNearbyLocations = [[NSMutableArray alloc]init];
    //self.arrayOfSearchedLocations = [[NSMutableArray alloc]init];
    
    [self configureSearchController];
    [self getCurrentLocation];
    
}

#pragma mark- TableView Delegate Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //if (!self.shouldShowSearchResults) {
        //self.arrayOfNearbyLocations.count
    return [self.result.mapItems count];
//    } else {
//        return [self.result.mapItems count];
//    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"LocationCell";
    UITableViewCell *locationsCell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

    MKMapItem *item = self.result.mapItems[indexPath.row];
    locationsCell.textLabel.text = item.name;
    locationsCell.detailTextLabel.text = item.placemark.title;
    
//    locationsCell.textLabel.text = [[[self.arrayOfNearbyLocations objectAtIndex:indexPath.row] mapItem] name];
//    locationsCell.detailTextLabel.text = [[[[self.arrayOfNearbyLocations objectAtIndex:indexPath.row]mapItem] placemark]title];

    return locationsCell;
}

#pragma mark- search Controller
- (void)configureSearchController {
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    self.searchController.searchBar.delegate = self;
    //self.navigationItem.titleView = self.searchController.searchBar;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.hidesNavigationBarDuringPresentation = YES;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.placeholder = @"Enter Address..";
    //self.definesPresentationContext = YES;
}

#pragma mark- current location
-(void)getCurrentLocation{
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager startUpdatingLocation];
}

#pragma mark- updating Location

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"%@", error.localizedDescription);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *newLocation = [locations lastObject]; //maybe firstObject
    CLLocation *oldLocation;
    if (locations.count > 1) {
        oldLocation = [locations objectAtIndex:locations.count-2];
    } else {
        oldLocation = nil;
    }
    NSLog(@"didUpdateToLocation %@ from %@", newLocation, oldLocation);
    MKCoordinateRegion userLocation = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1500.00, 1500.00);
    
    self.currentLocation = &(userLocation);
    [self performSearch:userLocation];
    
//    NSLog(@"current location:  %@", locations.firstObject);
//    self.currentLocation = locations.firstObject;
//    NSLog(@"%@", self.currentLocation);
//    [self.locationManager stopUpdatingLocation];
//    [self findNearbyLocations:self.currentLocation];
}

#pragma mark- Search Method
-(void)performSearch:(MKCoordinateRegion)aRegion{
    //cancel previous searches
    [self.localSreach cancel];
    [self.locationManager stopUpdatingLocation];

    // Perform a new Search
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc]init];
    if (!self.shouldShowSearchResults) {
        request.naturalLanguageQuery = @"Landmark";
    } else {
        request.naturalLanguageQuery = self.searchTerm;
    }
    
    request.region = aRegion;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.localSreach = [[MKLocalSearch alloc]initWithRequest:request];

    [self.localSreach startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (error != nil) {
            NSLog(@"error is: %@", error.localizedDescription);
        }
        
        if ([response.mapItems count] == 0) {
            NSLog(@"No result");
        }else {
            self.result = response;
        }
        
        // what happens here?
        [self.tableView reloadData];
    }];
    
    NSLog(@"DEBUG");
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    self.shouldShowSearchResults = YES;
    [self.tableView reloadData];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.shouldShowSearchResults = NO;
    [self.tableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchController.searchBar resignFirstResponder];
//    if (!self.shouldShowSearchResults) {
//        self.shouldShowSearchResults = YES;
//        self.searchTerm = searchBar.text;
//        [self performSearch:*(self.currentLocation)];
//
//        [self.tableView reloadData];
//    }
}

//-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
//    if (searchController.searchBar.text != nil) {
//        self.searchTerm = searchController.searchBar.text;
//        self.shouldShowSearchResults = YES;
//    } else {
//        self.shouldShowSearchResults = NO;
//    }
//    
//}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    self.shouldShowSearchResults = YES;
    self.searchTerm = searchText;
    NSLog(@"test is %@", searchText);
    [self performSearch:*(self.currentLocation)];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    //    NSLog(@"items in array = %@", );
    //
    //    NSLog(@"INDEXPATH: %ld", (long)indexPath.row);
    //    self.selectedLocation = [self.arrayOfNearbyLocations objectAtIndex:indexPath.row];
    //    NSLog(@"didSelect selectedLocation = %@", self.selectedLocation.mapItem.name);

    if ([segue.identifier isEqualToString:@"LocationCellSelected"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSLog(@"%ld", (long)indexPath.row);
        PostImageVC *desVC = segue.destinationViewController;
        NearbyLocation *nearbyLocation = [[NearbyLocation alloc]init];

        MKMapItem *mapItem = self.result.mapItems[indexPath.row];
        nearbyLocation.mapItem = mapItem;
        desVC.passedSelectedLocation = nearbyLocation;
        NSLog(@"%@", desVC.passedSelectedLocation.mapItem.name);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
//    
//    self.arrayOfSearchedLocations = [[NSMutableArray alloc]init];
//    self.arrayOfNearbyLocations = [[NSMutableArray alloc]init];
//    
//    [self configureSearchController];
//    
//    //when true, the filteredArrayOfPosts will be used
//    self.shouldShowSearchResults = NO;
//    
//    [self updateCurrentLocation];
//    [self.tableView reloadData];
//}
//
//-(void)updateCurrentLocation{
//    self.locationManager = [[CLLocationManager alloc]init];
//    self.locationManager.delegate = self;
//    
//    [self.locationManager requestWhenInUseAuthorization];
//    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
//    [self.locationManager startUpdatingLocation];
//}
//
//#pragma mark- Location
//
//-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
//    NSLog(@"%@", error.localizedDescription);
//}
//
//-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
//    NSLog(@"current location:  %@", locations.firstObject);
//    self.currentLocation = locations.firstObject;
//    NSLog(@"%@", self.currentLocation);
//    [self.locationManager stopUpdatingLocation];
//    [self findNearbyLocations:self.currentLocation];
//}
//
//-(void)findNearbyLocations:(CLLocation *)location {
//    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
//    if (!self.shouldShowSearchResults) {
//        //10- "cafe", "landmark"
//        request.naturalLanguageQuery = @"landmark";
//    } else {
//        request.naturalLanguageQuery = self.searchTerm;
//    }
//    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(.5, .5));
//    
//    MKLocalSearch *search = [[MKLocalSearch alloc]initWithRequest:request];
//    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
//        NSArray *mapItems = response.mapItems;
//        NSMutableArray *temporaryArray = [NSMutableArray new];
//        for (int i = 0; i < mapItems.count; i++)
//        {
//            MKMapItem *mapItem = [mapItems objectAtIndex:i];
//            
//            CLLocationDistance metersAway = [mapItem.placemark.location distanceFromLocation:location];
//            float milesDifference = metersAway / 1609.34;
//            
//            NearbyLocation *nearbyLocation = [[NearbyLocation alloc]init];
//            nearbyLocation.mapItem = mapItem;
//            nearbyLocation.milesDifference = milesDifference;
//            [temporaryArray addObject:nearbyLocation];
//        }
//        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"milesDifference" ascending:true];
//        NSArray *sortedArray = [temporaryArray sortedArrayUsingDescriptors:@[sortDescriptor]];
//        //self.arrayOfSearchedLocations = [NSMutableArray arrayWithArray:sortedArray];
//        self.arrayOfNearbyLocations = [NSMutableArray arrayWithArray:sortedArray];
//        
//        [self.tableView reloadData];
//    }];
//}
//
//#pragma mark- TableView
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    if (!self.shouldShowSearchResults) {
//        return self.arrayOfNearbyLocations.count;
//    } else {
//        return self.arrayOfSearchedLocations.count;
//    }
//}
//
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell *locationsCell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell" forIndexPath:indexPath];
//    
//    locationsCell.textLabel.text = [[[self.arrayOfNearbyLocations objectAtIndex:indexPath.row] mapItem] name];
//    locationsCell.detailTextLabel.text = [[[[self.arrayOfNearbyLocations objectAtIndex:indexPath.row]mapItem] placemark]title];
//    
//    return locationsCell;
//}
//
//#pragma mark- search Controller
//- (void)configureSearchController {
//    self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
//    self.searchController.searchBar.delegate = self;
//    //self.navigationItem.titleView = self.searchController.searchBar;
//    self.tableView.tableHeaderView = self.searchController.searchBar;
//    self.searchController.hidesNavigationBarDuringPresentation = YES;
//    self.searchController.dimsBackgroundDuringPresentation = NO;
//    self.searchController.searchBar.placeholder = @"Enter Address..";
//    //self.definesPresentationContext = YES;
//}
//
//-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
//    self.shouldShowSearchResults = YES;
//    [self.tableView reloadData];
//}
//
//-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
//    self.shouldShowSearchResults = NO;
//    [self.tableView reloadData];
//}
//
//-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
//    if (!self.shouldShowSearchResults) {
//        self.shouldShowSearchResults = YES;
//        self.searchTerm = searchBar.text;
//        [self findNearbyLocations:self.currentLocation];
//        
//        //[self.tableView reloadData];
//    }
//    [self.searchController.searchBar resignFirstResponder];
//}
//
//-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
//    if (searchController.searchBar.text != nil) {
//        self.searchTerm = searchController.searchBar.text;
//        self.shouldShowSearchResults = YES;
//    } else {
//        self.shouldShowSearchResults = NO;
//    }
//    
//}
//
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    
//    //    NSLog(@"items in array = %@", );
//    //
//    //    NSLog(@"INDEXPATH: %ld", (long)indexPath.row);
//    //    self.selectedLocation = [self.arrayOfNearbyLocations objectAtIndex:indexPath.row];
//    //    NSLog(@"didSelect selectedLocation = %@", self.selectedLocation.mapItem.name);
//    
//    if ([segue.identifier isEqualToString:@"LocationCellSelected"]) {
//        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
//        PostImageVC *desVC = segue.destinationViewController;
//        
//        desVC.passedSelectedLocation = [self.arrayOfNearbyLocations objectAtIndex:indexPath.row];
//    }
//}
