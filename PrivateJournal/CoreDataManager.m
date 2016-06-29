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
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));
    NSError *error;
    if ([moc save:&error]) {
        NSLog(@"core save ok");
    } else {
         NSLog(@">>> core save error: %@", error);
    }
}

+ (void)deleteObject:(NSManagedObject *)x{
    initMoc();
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));
    [moc deleteObject:x];
}

//Not Sure what this fetchAllOfTypeDoes
+ (NSArray *)fetchAllOfType:(NSString *)entityType {
    initMoc();
    NSLog(@"[%@ %@] %@", self.class, NSStringFromSelector(_cmd), entityType);
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

#pragma mark - Pictures
+ (Picture *)addPicture:(UIImage *)pictureImage withComment:(NSString *)commentStr {
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));
    initMoc();
    
//    Comment *c = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:moc];
//    c.text = commentStr;
//    c.time = [NSDate date];
//    //c.user = user;
    
    Picture *p = [NSEntityDescription insertNewObjectForEntityForName:@"Picture" inManagedObjectContext:moc];
    p.image = UIImagePNGRepresentation(pictureImage);
    p.location = @"somewhere in the desert, New Mexico"; // TODO
    p.time = [NSDate date];
//    p.owner = user;
//    [p addCommentsObject:c];
    
    for (NSString *tagText in [self findHashtagsIn:commentStr]) {
        // check if hashtag exists
        Hashtag *h = [self fetchHashtag:tagText];
        if (!h) {
            // new hashtag
            NSLog(@"new hashtag >%@<", tagText);
            h = [NSEntityDescription insertNewObjectForEntityForName:@"Hashtag" inManagedObjectContext:moc];
            h.tagtext = tagText;
        } else {
            NSLog(@"old hashtag >%@<", tagText);
        }
//        [h addCommentsObject:c];
    }
    
    return p;
}

#pragma mark - Hashtags
+ (Hashtag *)fetchHashtag:(NSString *)tag {
    NSLog(@"[%@ %@] %@", self.class, NSStringFromSelector(_cmd), tag);
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
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));
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
