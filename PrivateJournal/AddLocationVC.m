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
    
    [self configureSearchController];
    [self getCurrentLocation];
    
}

#pragma mark- TableView Delegate Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.result.mapItems count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"LocationCell";
    UITableViewCell *locationsCell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

    MKMapItem *item = self.result.mapItems[indexPath.row];
    locationsCell.textLabel.text = item.name;
    locationsCell.detailTextLabel.text = item.placemark.title;

    return locationsCell;
}

#pragma mark- search Controller
- (void)configureSearchController {
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    self.searchController.searchBar.delegate = self;
    self.searchController.hidesNavigationBarDuringPresentation = YES;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.placeholder = @"Enter Address..";

    self.tableView.tableHeaderView = self.searchController.searchBar;

    //self.navigationItem.titleView = self.searchController.searchBar;
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
    MKCoordinateRegion userLocation = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1500.00, 1500.00);
    
    self.currentLocation = &(userLocation);
    [self performSearch:userLocation];
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
        
        [self.tableView reloadData];
    }];
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
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    self.shouldShowSearchResults = YES;
    self.searchTerm = searchText;
    [self performSearch:*(self.currentLocation)];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"LocationCellSelected"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        PostImageVC *desVC = segue.destinationViewController;
        NearbyLocation *nearbyLocation = [[NearbyLocation alloc]init];

        MKMapItem *mapItem = self.result.mapItems[indexPath.row];
        nearbyLocation.mapItem = mapItem;
        desVC.passedSelectedLocation = nearbyLocation;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end