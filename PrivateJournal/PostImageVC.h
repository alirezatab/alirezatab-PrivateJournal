//
//  PostImageVC.h
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 6/29/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NearbyLocation.h"
#import "Picture.h"

@interface PostImageVC : UITableViewController
@property UIImage *snappedImage;
@property NearbyLocation *passedSelectedLocation;
@end