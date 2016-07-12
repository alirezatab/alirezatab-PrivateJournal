//
//  PostDetailVC.h
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 7/8/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Picture.h"

///Decide how to display image to users
@interface PostDetailVC : UIViewController
@property NSIndexPath *passedIndexPath;

@property UIImage *detailPictureObject;
@property NSString *detailPictureObjectLocation;

@property User *me;
@end