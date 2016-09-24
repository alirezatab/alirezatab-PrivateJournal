//
//  CoreDataManager.m
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 6/29/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import "CoreDataManager.h"
#import "AppDelegate.h"
#import "Picture.h"

@implementation CoreDataManager
static NSManagedObjectContext *moc;

#pragma mark - primitive
void initMoc(void){
    if (!moc) {
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        moc = appDelegate.managedObjectContext;
    }
}

+ (void)save {
    initMoc();
    NSError *error;
    if ([moc save:&error]) {
        NSLog(@"core save ok");
    } else {
         NSLog(@">>> core save error: %@", error);
    }
}

+ (void)deleteObject:(NSManagedObject *)entity{
    initMoc();
    [moc deleteObject:entity];
}

+ (void)editObject:(NSManagedObject *)entity{
    initMoc();
    
    [moc refreshObject:entity mergeChanges:YES];
}

+ (NSArray *)fetchAllOfType:(NSString *)entityType {
    initMoc();
    NSFetchRequest *req = [[NSFetchRequest alloc] initWithEntityName:entityType];
    NSError *error;
    NSArray *fetchedObjects = [moc executeFetchRequest:req error:&error];
    if (!error) {
        NSLog(@"core load ok: %lu %@s", (unsigned long)fetchedObjects.count, entityType);
    } else {
        NSLog(@"core load error: %@", error);
    }
    return fetchedObjects;
}

#pragma mark - Pictures
+ (Picture *)addPicture:(UIImage *)pictureImage withComment:(NSString *)commentStr withLocation:(NSString *)locationStr {
    initMoc();
    
    Picture *p = [NSEntityDescription insertNewObjectForEntityForName:@"Picture" inManagedObjectContext:moc];
    p.image = UIImagePNGRepresentation(pictureImage);
    p.location = locationStr;
    p.time = [NSDate date];
    p.comment = commentStr;
    
    return p;
}

@end
