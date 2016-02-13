//
//  YTDBManager.m
//  CoreData-GH.LS12
//
//  Created by Yuriy T on 06.02.16.
//  Copyright © 2016 Yuriy T. All rights reserved.
//

#import "YTDBManager.h"

@implementation YTDBManager

#pragma mark - SingleTone Constructor

+ (YTDBManager *) Manager {
    static YTDBManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YTDBManager alloc] init];
    });
    
    return manager;
}

#pragma mark - Queries

- (NSArray *) getAllBaskets {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"YTBasket" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:description];
    [request setFetchBatchSize:25];
    
    NSSortDescriptor *sortByCreated = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    [request setSortDescriptors:@[sortByCreated]];
    
    NSError *error = nil;
    NSArray *result = nil;
    if (!(result = [self.managedObjectContext executeFetchRequest:request error:&error])) {
        NSLog(@"GetAll error: %@", [error localizedDescription]);
    }
    
    return result;
}

-(void) removeAllBasckets {
    
    NSArray *all = [self getAllBaskets];
    NSError *errorReq = nil;
    
    //  Delete
    for (id object in all) {
        [self.managedObjectContext deleteObject:object];
    }
    
    if(![self.managedObjectContext save:&errorReq]){
        NSLog(@"%@", [errorReq localizedDescription]);
    }
}

- (NSArray *) getProductsInBasketWithId:(NSManagedObjectID *) objectId {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"YTProduct" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:description];
    [request setFetchBatchSize:25];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"basket = %@", objectId];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    [request setSortDescriptors:@[sortByTitle]];
    
    NSError *error = nil;
    NSArray *result = nil;
    if (!(result = [self.managedObjectContext executeFetchRequest:request error:&error])) {
        NSLog(@"GetAll error: %@", [error localizedDescription]);
    }
    
    return result;
}

-(YTBasket *) getBasketByID:(NSManagedObjectID *) objectId {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:[[YTBasket class] description] inManagedObjectContext:self.managedObjectContext];
    [request setEntity:description];
    
    NSError *error = nil;
    YTBasket *result = nil;
    if (!(result = [self.managedObjectContext existingObjectWithID:objectId error:&error])) {
        NSLog(@"GetAll error: %@", [error localizedDescription]);
    }
    
    return result;
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.learning.Objective-C.CoreData_GH_LS12" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CoreData_GH_LS12" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CoreData_GH_LS12.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                        
            abort();
        }
    }
}

@end
