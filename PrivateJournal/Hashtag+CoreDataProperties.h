//
//  Hashtag+CoreDataProperties.h
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 7/3/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Hashtag.h"

NS_ASSUME_NONNULL_BEGIN

@interface Hashtag (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *tagtext;
@property (nullable, nonatomic, retain) NSSet<Comment *> *comments;

@end

@interface Hashtag (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet<Comment *> *)values;
- (void)removeComments:(NSSet<Comment *> *)values;

@end

NS_ASSUME_NONNULL_END
