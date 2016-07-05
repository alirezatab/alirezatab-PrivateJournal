//
//  HomeVC.h
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 6/12/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Picture.h"

@interface HomeVC : UIViewController
@property User *user;
@property NSArray *arrayOfPosts;

@property Picture *scrollToPost;
@end
