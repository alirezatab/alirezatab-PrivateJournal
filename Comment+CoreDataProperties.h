//
//  Comment+CoreDataProperties.h
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 9/15/16.
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
@property (nullable, nonatomic, retain) Picture *picture;

@end

NS_ASSUME_NONNULL_END
