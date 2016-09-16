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


@interface CoreDataManager : NSObject 
+ (Picture *)addPicture:(UIImage *)pictureImage
            withComment:(NSString *)commentStr withLocation:(NSString *)locationStr;
+ (void)deleteObject:(NSManagedObject *)entity;
+ (void)editObject:(NSManagedObject *)entity;
+ (void)save;
+ (NSArray *)fetchComments;
@end
