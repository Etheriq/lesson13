//
//  YTBasketViewController.m
//  CoreData-GH.LS12
//
//  Created by Yuriy T on 06.02.16.
//  Copyright © 2016 Yuriy T. All rights reserved.
//

#import "YTBasketViewController.h"
#import "YTDBManager.h"
#import "YTBasket.h"

@interface YTBasketViewController ()

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UIDatePicker *createdDatePicker;

@end

@implementation YTBasketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"New basket";
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (IBAction)createBascket:(UIButton *)sender {
   
    YTBasket *bascket = nil;
    NSManagedObjectContext *context = [YTDBManager Manager].managedObjectContext;
    
    bascket = [NSEntityDescription insertNewObjectForEntityForName:[[YTBasket class] description] inManagedObjectContext:context];
    bascket.title = self.titleField.text;
    bascket.createdAt = self.createdDatePicker.date;
    
    NSError *error = nil;
    if ([context save:&error] == NO) {
        
        [self showAlertWithError:error];
        error = nil;
    } else {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Error handle

- (void)showAlertWithError:(NSError *) error {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Could Not Save Data"
                                                        message:[NSString stringWithFormat:@"%@", error.domain]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

@end
