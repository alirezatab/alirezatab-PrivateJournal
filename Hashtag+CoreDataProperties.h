//
//  Hashtag+CoreDataProperties.h
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 6/13/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Hashtag.h"

NS_ASSUME_NONNULL_BEGIN

@interface Hashtag (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *tagtext;
@property (nullable, nonatomic, retain) NSSet<Picture *> *picture;

@end

@interface Hashtag (CoreDataGeneratedAccessors)

- (void)addPictureObject:(Picture *)value;
- (void)removePictureObject:(Picture *)value;
- (void)addPicture:(NSSet<Picture *> *)values;
- (void)removePicture:(NSSet<Picture *> *)values;

@end

NS_ASSUME_NONNULL_END
