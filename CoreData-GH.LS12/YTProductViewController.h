//
//  YTProductViewController.h
//  CoreData-GH.LS12
//
//  Created by Yuriy T on 07.02.16.
//  Copyright © 2016 Yuriy T. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTProduct.h"

@interface YTProductViewController : UIViewController

@property(strong, nonatomic) id basketID;
@property (strong, nonatomic) YTProduct *product;

@end
