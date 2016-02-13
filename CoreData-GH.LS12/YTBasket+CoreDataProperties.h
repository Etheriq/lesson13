//
//  YTBasket+CoreDataProperties.h
//  CoreData-GH.LS12
//
//  Created by Yuriy T on 06.02.16.
//  Copyright © 2016 Yuriy T. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "YTBasket.h"

NS_ASSUME_NONNULL_BEGIN

@interface YTBasket (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSSet<YTProduct *> *products;

@end

@interface YTBasket (CoreDataGeneratedAccessors)

- (void)addProductsObject:(YTProduct *)value;
- (void)removeProductsObject:(YTProduct *)value;
- (void)addProducts:(NSSet<YTProduct *> *)values;
- (void)removeProducts:(NSSet<YTProduct *> *)values;

@end

NS_ASSUME_NONNULL_END
