//
//  YTBascketCell.h
//  CoreData-GH.LS12
//
//  Created by Yuriy T on 06.02.16.
//  Copyright © 2016 Yuriy T. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YTBascketCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *createdAtDate;
@property (weak, nonatomic) IBOutlet UILabel *productCountLabel;

@end
