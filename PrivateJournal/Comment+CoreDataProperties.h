//
//  Comment+CoreDataProperties.h
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 7/3/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Comment.h"

NS_ASSUME_NONNULL_BEGIN

@interface Comment (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSDate *time;
@property (nullable, nonatomic, retain) NSSet<Hashtag *> *hashtags;
@property (nullable, nonatomic, retain) Picture *picture;
@property (nullable, nonatomic, retain) User *user;

@end

@interface Comment (CoreDataGeneratedAccessors)

- (void)addHashtagsObject:(Hashtag *)value;
- (void)removeHashtagsObject:(Hashtag *)value;
- (void)addHashtags:(NSSet<Hashtag *> *)values;
- (void)removeHashtags:(NSSet<Hashtag *> *)values;

@end

NS_ASSUME_NONNULL_END
