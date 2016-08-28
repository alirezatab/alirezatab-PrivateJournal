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
@property NSMutableArray *arrayOfNearbyLocations;
@property NSMutableArray *arrayOfSearchedLocations;
@property CLLocation *currentLocation;
@property NSString *searchTerm;
@property BOOL shouldShowSearchResults;
@end

@implementation AddLocationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arrayOfSearchedLocations = [[NSMutableArray alloc]init];
    
    [self configureSearchController];
    
    //when true, the filteredArrayOfPosts will be used
    self.shouldShowSearchResults = NO;
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    [self updateCurrentLocation];
}

-(void)updateCurrentLocation{
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}

#pragma mark- Location
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.currentLocation = locations.firstObject;
    NSLog(@"%@", self.currentLocation);
    [self.locationManager stopUpdatingLocation];
    [self findNearbyLocations:self.currentLocation];
}

#pragma mark- TableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (!self.shouldShowSearchResults) {
        return self.arrayOfNearbyLocations.count;
    } else {
        return self.arrayOfSearchedLocations.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *locationsCell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell" forIndexPath:indexPath];
    
    locationsCell.textLabel.text = [[[self.arrayOfNearbyLocations objectAtIndex:indexPath.row] mapItem] name];
    locationsCell.detailTextLabel.text = [[[[self.arrayOfNearbyLocations objectAtIndex:indexPath.row]mapItem] placemark]title];
    
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

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    self.shouldShowSearchResults = YES;
    [self.tableView reloadData];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.shouldShowSearchResults = NO;
    [self.tableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (!self.shouldShowSearchResults) {
        self.shouldShowSearchResults = YES;
        self.searchTerm = searchBar.text;
        [self findNearbyLocations:self.currentLocation];

        //[self.tableView reloadData];
    }
    [self.searchController.searchBar resignFirstResponder];
}

//-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
//    
//    self.arrayOfSearchedLocations = [[NSMutableArray alloc]init];
//}

-(void)findNearbyLocations:(CLLocation *)location {
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    if (!self.shouldShowSearchResults) {
        request.naturalLanguageQuery = @"Resturant";
    } else {
        request.naturalLanguageQuery = self.searchTerm;
    }
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(10000.05, 10000.05));
    
    MKLocalSearch *search = [[MKLocalSearch alloc]initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        NSArray *mapItems = response.mapItems;
        NSMutableArray *temporaryArray = [NSMutableArray new];
        for (int i = 0; i < mapItems.count; i++)
        {
            MKMapItem *mapItem = [mapItems objectAtIndex:i];
            
            CLLocationDistance metersAway = [mapItem.placemark.location distanceFromLocation:location];
            float milesDifference = metersAway / 1609.34;
            
            NearbyLocation *nearbyLocation = [[NearbyLocation alloc]init];
            nearbyLocation.mapItem = mapItem;
            nearbyLocation.milesDifference = milesDifference;
            [temporaryArray addObject:nearbyLocation];
        }
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"milesDifference" ascending:true];
        NSArray *sortedArray = [temporaryArray sortedArrayUsingDescriptors:@[sortDescriptor]];
        //self.arrayOfSearchedLocations = [NSMutableArray arrayWithArray:sortedArray];
        self.arrayOfNearbyLocations = [NSMutableArray arrayWithArray:sortedArray];

        [self.tableView reloadData];
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
//    NSLog(@"items in array = %@", );
//    
//    NSLog(@"INDEXPATH: %ld", (long)indexPath.row);
//    self.selectedLocation = [self.arrayOfNearbyLocations objectAtIndex:indexPath.row];
//    NSLog(@"didSelect selectedLocation = %@", self.selectedLocation.mapItem.name);
    
    if ([segue.identifier isEqualToString:@"LocationCellSelected"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        PostImageVC *desVC = segue.destinationViewController;

        desVC.passedSelectedLocation = [self.arrayOfNearbyLocations objectAtIndex:indexPath.row];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
