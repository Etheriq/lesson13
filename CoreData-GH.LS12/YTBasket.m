//
//  YTBasket.m
//  CoreData-GH.LS12
//
//  Created by Yuriy T on 06.02.16.
//  Copyright © 2016 Yuriy T. All rights reserved.
//

#import "YTBasket.h"
#import "YTProduct.h"

@implementation YTBasket

// Insert code here to add functionality to your managed object subclass

- (BOOL) validateTitle:(id  _Nullable __autoreleasing *)value error:(NSError * _Nullable __autoreleasing *)error {
    
    if ([*value isEqual: @""]) {
        *error = [NSError errorWithDomain:@"Basket title must be non empty" code:103 userInfo:nil];
        return NO;
    }
    
    return YES;
}

@end
