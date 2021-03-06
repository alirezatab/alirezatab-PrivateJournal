//
//  AppDelegate.h
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 6/8/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (BOOL)saveContext:(NSManagedObjectContext*)context;
- (NSURL *)applicationDocumentsDirectory;


@end

