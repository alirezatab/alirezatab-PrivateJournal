//
//  NearbyLocation.h
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 7/21/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface NearbyLocation : NSObject
@property MKMapItem *mapItem;
@property float milesDifference;
@end
