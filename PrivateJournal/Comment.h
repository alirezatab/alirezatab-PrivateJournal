//
//  Comment.h
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 7/3/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Hashtag, Picture, User;

NS_ASSUME_NONNULL_BEGIN

@interface Comment : NSManagedObject

-(NSString *)agoString;

@end

NS_ASSUME_NONNULL_END

#import "Comment+CoreDataProperties.h"
