//
//  CoreDataManager.h
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 6/29/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Picture.h"
#import "Hashtag.h"


@interface CoreDataManager : NSObject
+ (Picture *)addPicture:(UIImage *)pictureImage
            withComment:(NSString *)commentStr
               fromUser:(User *)user;
+ (void)deleteObject:(NSManagedObject *)x;
+ (void)save;
//+ (NSArray *)fetchComments;
+ (NSArray *)fetchUsers;
+ (Hashtag *)fetchHashtag:(NSString *)tag;
+ (User *)getUserZero;
@end
