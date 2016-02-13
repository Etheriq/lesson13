//
//  YTProductViewController.m
//  CoreData-GH.LS12
//
//  Created by Yuriy T on 07.02.16.
//  Copyright © 2016 Yuriy T. All rights reserved.
//

#import "YTProductViewController.h"
#import "YTDBManager.h"

@interface YTProductViewController ()
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UIStepper *stepperamount;
@property (weak, nonatomic) IBOutlet UITextField *priceField;
@property (weak, nonatomic) IBOutlet UILabel *currentAmountLabel;

@property (strong, nonatomic) YTBasket *basket;


@end

@implementation YTProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentAmountLabel.text = [NSString stringWithFormat:@"%i", (int)self.stepperamount.value];
    self.basket = [[YTDBManager Manager] getBasketByID:self.basketID];
    
    [self fillDataToForm];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) fillDataToForm {
    
    if (self.product) {
        self.titleField.text = _product.title;
        self.stepperamount.value = [_product.amount doubleValue];
        self.priceField.text = [NSString stringWithFormat:@"%.2f", [_product.price floatValue]];
        self.currentAmountLabel.text = [NSString stringWithFormat:@"%i", (int)self.stepperamount.value];
    }
}

#pragma mark - Actions

- (IBAction)submit:(UIButton *)sender {
    
    NSManagedObjectContext *context = [YTDBManager Manager].managedObjectContext;
    if (!self.product) {
        self.product = [NSEntityDescription insertNewObjectForEntityForName:[[YTProduct class] description] inManagedObjectContext:context];
        self.product.isPurchased = [NSNumber numberWithBool:NO];
    }
    
    self.product.title = self.titleField.text;
    self.product.amount = [NSNumber numberWithDouble:self.stepperamount.value];
    self.product.price = [NSDecimalNumber decimalNumberWithString:self.priceField.text];
    self.product.basket = self.basket;
    
    NSError *error = nil;
    if ([context save:&error] == NO) {
        [self showAlertWithError:error];
    } else {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)changeAmount:(UIStepper *)sender {
    
    self.currentAmountLabel.text = [NSString stringWithFormat:@"%i", (int)sender.value];
    
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
