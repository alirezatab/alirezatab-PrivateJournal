//
//  NSManagedObjectContext+Concurrent.h
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 9/16/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Concurrent)

- (void)performGroupedBlock:(dispatch_block_t)block;
- (dispatch_group_t)dispatchGroup;
- (dispatch_group_t)setupDispatchGroup;

@end
