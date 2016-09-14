//
//  CoreDataManager.h
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 6/29/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Picture.h"
#import "Hashtag.h"


@interface CoreDataManager : NSObject 
+ (Picture *)addPicture:(UIImage *)pictureImage
            withComment:(NSString *)commentStr withLocation:(NSString *)locationStr fromUser:(User *)user;

+ (NSFetchedResultsController *)fetchEntityWithClassName:(NSString *)className sortDescriptyor:(NSArray *)sortDescriptors sectionNameKeyPath:(NSString *)sectionNameKeypath predicate:(NSPredicate *)predicate;
+ (void)deleteObject:(NSManagedObject *)entity;
+ (void)editObject:(NSManagedObject *)entity;
+ (void)save;
+ (NSArray *)fetchComments;
+ (NSArray *)fetchUsers;
+ (Hashtag *)fetchHashtag:(NSString *)tag;
+ (User *)getUserZero;
@end
