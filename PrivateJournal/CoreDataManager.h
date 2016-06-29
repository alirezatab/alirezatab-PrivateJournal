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
            withComment:(NSString *)commentStr;
+ (void)deleteObject:(NSManagedObject *)x;
+ (void)save;
+ (Hashtag *)fetchHashtag:(NSString *)tag;
@end
