//
//  Picture+CoreDataProperties.h
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 6/13/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Picture.h"

NS_ASSUME_NONNULL_BEGIN

@interface Picture (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *image;
@property (nullable, nonatomic, retain) NSString *location;
@property (nullable, nonatomic, retain) NSDate *time;
@property (nullable, nonatomic, retain) NSSet<NSManagedObject *> *hashtags;

@end

@interface Picture (CoreDataGeneratedAccessors)

- (void)addHashtagsObject:(NSManagedObject *)value;
- (void)removeHashtagsObject:(NSManagedObject *)value;
- (void)addHashtags:(NSSet<NSManagedObject *> *)values;
- (void)removeHashtags:(NSSet<NSManagedObject *> *)values;

@end

NS_ASSUME_NONNULL_END
