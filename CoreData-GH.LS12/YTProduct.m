//
//  YTProduct.m
//  CoreData-GH.LS12
//
//  Created by Yuriy T on 06.02.16.
//  Copyright © 2016 Yuriy T. All rights reserved.
//

#import "YTProduct.h"

@implementation YTProduct

// Insert code here to add functionality to your managed object subclass


 - (BOOL) validateTitle:(id  _Nullable __autoreleasing *)value error:(NSError * _Nullable __autoreleasing *)error {
 
     if ([*value isEqual: @""]) {
        *error = [NSError errorWithDomain:@"Product title must be non empty" code:101 userInfo:nil];
        return NO;
     }
     
     return YES;
 }

- (BOOL) validatePrice:(id  _Nullable __autoreleasing *)value error:(NSError * _Nullable __autoreleasing *)error {
    
    if ([*value floatValue] <= 0.0) {
        *error = [NSError errorWithDomain:@"Product price must be more zero" code:102 userInfo:nil];
        return NO;
    }
    
    return YES;
}

@end
