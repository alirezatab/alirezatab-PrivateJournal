//
//  CoreDataManager.m
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 6/29/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import "CoreDataManager.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "Picture.h"
#import "Hashtag.h"
#import "Comment.h"
#import "User.h"

@implementation CoreDataManager
static NSManagedObjectContext *moc;

#pragma mark - primitive
void initMoc(void){
    if (!moc) {
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
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

+ (void)deleteObject:(NSManagedObject *)x{
    initMoc();
    [moc deleteObject:x];
}

+ (void)editObject:(NSManagedObject *)y{
    initMoc();
    
    [moc refreshObject:y mergeChanges:YES];
}

+ (NSArray *)fetchAllOfType:(NSString *)entityType {
    initMoc();
    NSFetchRequest *req = [[NSFetchRequest alloc] initWithEntityName:entityType];
    NSError *error;
    NSArray *fetchedObjects = [moc executeFetchRequest:req error:&error];
    if (!error) {
        NSLog(@"core load ok: %lu %@s", fetchedObjects.count, entityType);
    } else {
        NSLog(@"core load error: %@", error);
    }
    return fetchedObjects;
}

#pragma mark - Comments
+ (NSArray *)fetchComments {
    return [self fetchAllOfType:@"Comment"];
}

#pragma mark - Users
+ (NSArray *)fetchUsers {
    NSArray *users = [self fetchAllOfType:@"User"];
    if (users.count == 0) {
        users = [CoreDataManager dummyData];
    }
    return users;
}
+ (User *)getUserZero {
    return [self fetchUsers][0];
}
+ (NSArray *)dummyData {
    initMoc();
    
    // User
    User *u = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:moc];
    u.username = @"heisenberg0";
    u.fullname = @"Walter White";
    
//    [CoreDataManager addPicture:[UIImage imageNamed:@"heisenberg-image1"] withComment:@"laundry day" fromUser:u];
//    [CoreDataManager addPicture:[UIImage imageNamed:@"heisenberg-image2"] withComment:@"kicking it with Jesse" fromUser:u];
    [CoreDataManager save];
    
    NSArray *users = @[u];
    User *u2 = users[0];
    return users;
}

#pragma mark - Pictures
+ (Picture *)addPicture:(UIImage *)pictureImage withComment:(NSString *)commentStr withLocation:(NSString *)locationStr fromUser:(User *)user {
    initMoc();
    
    Comment *c = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:moc];
    c.text = commentStr;
    c.time = [NSDate date];
    c.user = user;
    
    Picture *p = [NSEntityDescription insertNewObjectForEntityForName:@"Picture" inManagedObjectContext:moc];
    p.image = UIImagePNGRepresentation(pictureImage);
    p.location = locationStr;
    p.time = [NSDate date];
    p.owner = user;
    [p addCommentsObject:c];
    
    for (NSString *tagText in [self findHashtagsIn:commentStr]) {
        // check if hashtag exists
        Hashtag *h = [self fetchHashtag:tagText];
        if (!h) {
            // new hashtag
            h = [NSEntityDescription insertNewObjectForEntityForName:@"Hashtag" inManagedObjectContext:moc];
            h.tagtext = tagText;
        } else {
            NSLog(@"old hashtag >%@<", tagText);
        }
        [h addCommentsObject:c];
    }
    
    return p;
}


#pragma mark - Hashtags
+ (Hashtag *)fetchHashtag:(NSString *)tag {
    initMoc();
    
    NSFetchRequest *req = [[NSFetchRequest alloc] initWithEntityName:@"Hashtag"];
    req.predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"tagtext", tag];
    //NSLog(@"=> fetching >%@<", req.predicate.predicateFormat);
    NSError *error;
    NSArray *fetchedObjects = [moc executeFetchRequest:req error:&error];
    if (!error) {
        //NSLog(@"=> fetched %i tags >%@<", fetchedObjects.count, req.predicate.predicateFormat);
    } else {
        NSLog(@"core load error: %@", error);
    }
    return (fetchedObjects.count > 0) ? (fetchedObjects[0]) : (nil);
}

+(NSArray *)findHashtagsIn:(NSString *)text {
    NSArray *words = [text componentsSeparatedByString:@" "];
    NSMutableArray *hashtags = [NSMutableArray new];
    for (NSString *word in words) {
        if (word.length > 0 && [word characterAtIndex:0] == '#') {
            [hashtags addObject:word];
        }
    }
    return [NSArray arrayWithArray:hashtags];
}

@end
