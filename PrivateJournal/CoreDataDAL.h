//
//  CoreDataDAL.h
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 9/16/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataDAL : NSObject

/**
 @description you can use a local NSManagedObjectContext to perform coredata operations the local context will be on a thread distint than mainthread, the context is distroyed once block is executed.
 @param block code to be executed
 @param completion once the block is executed completion is called returning YES for contextDidSave if data was persisted without problem
 
 
 **/
+ (void)saveInbackgroundOnPrivateQueue:(void(^)(NSManagedObjectContext *localContext))block
                            completion:(void(^)(BOOL contextDidSave))completion;

@end
