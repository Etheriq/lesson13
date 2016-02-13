//
//  YTDBManager.h
//  CoreData-GH.LS12
//
//  Created by Yuriy T on 06.02.16.
//  Copyright © 2016 Yuriy T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "YTBasket.h"

@interface YTDBManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

+ (YTDBManager *) Manager;

- (NSArray *) getAllBaskets;
-(void) removeAllBasckets;
- (NSArray *) getProductsInBasketWithId:(NSManagedObjectID *) objectId;
-(YTBasket *) getBasketByID:(NSManagedObjectID *) objectId;

@end
