//
//  HomeVC.h
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 6/12/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface HomeVC : UIViewController
@property NSArray *arrayOfPosts;
@property NSArray *filteredArrayOfPosts;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultController;
-(IBAction)handleLongPressToDelete:(UILongPressGestureRecognizer *)recognizer;

@end
