//
//  YTProductTableViewController.m
//  CoreData-GH.LS12
//
//  Created by Yuriy T on 07.02.16.
//  Copyright © 2016 Yuriy T. All rights reserved.
//

#import "YTProductTableViewController.h"
#import "YTDBManager.h"
#import "YTProductViewController.h"
#import "YTProduct.h"
#import "YTProductCell.h"

@interface YTProductTableViewController ()

@property (strong, nonatomic) NSMutableArray *products;
@property (strong, nonatomic) NSMutableArray *purchasedProducts;
@property (strong, nonatomic) IBOutlet UITableView *table;

@end

@implementation YTProductTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Products";
    
    
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addProductWithProduct:)];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) refreshTable {
    
    self.products = nil;
    self.purchasedProducts = nil;
    
    NSArray *totalProducts = [[YTDBManager Manager] getProductsInBasketWithId:self.basketId];
    
    self.products = [NSMutableArray array];
    self.purchasedProducts = [NSMutableArray array];
    
    for (YTProduct *product in totalProducts) {
        if ([product.isPurchased boolValue]) {
            [self.purchasedProducts addObject:product];
        } else {
            [self.products addObject:product];
        }
    }
    
    [self.table reloadData];
}

#pragma mark - Actions

-(void) addProductWithProduct: (nullable YTProduct *) product {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    YTProductViewController *productController = [sb instantiateViewControllerWithIdentifier:@"productControllerIdentifier"];
    productController.basketID = self.basketId;
    if ([product isKindOfClass:[YTProduct class]]) {
        productController.product = product;
    }
    
    [self.navigationController pushViewController:productController animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        return [self.products count];
    } else {
        return [self.purchasedProducts count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YTProductCell *cell = [tableView dequeueReusableCellWithIdentifier:@"product_cell" forIndexPath:indexPath];

    if (indexPath.section == 0) {
        YTProduct *product = [self.products objectAtIndex:indexPath.row];
        cell.productTileLabel.text = product.title;
        cell.productTileLabel.textColor = [UIColor blackColor];
        cell.productDescriptionLabel.text = [NSString stringWithFormat:@"amount %i x price $%.2f = $%.2f", [product.amount intValue], [product.price floatValue], ([product.amount intValue] * [product.price floatValue])];
    
    } else {
        YTProduct *product = [self.purchasedProducts objectAtIndex:indexPath.row];
        cell.productTileLabel.text = product.title;
        cell.productTileLabel.textColor = [UIColor greenColor];
        cell.productDescriptionLabel.text = [NSString stringWithFormat:@"amount %i x price $%.2f = $%.2f", [product.amount intValue], [product.price floatValue], ([product.amount intValue] * [product.price floatValue])];
    }
    
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0 && [self.products count]) {
        
        return [NSString stringWithFormat:@"Need buy this products"];
    }
    if (section == 1 && [self.purchasedProducts count]){
        
        return [NSString stringWithFormat:@"Purchased products"];
    }
    
    return nil;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    if (section == 1 && [self.purchasedProducts count]) {
        float total = 0;
        for (YTProduct *product in self.purchasedProducts) {
            total += [product.amount intValue] * [product.price floatValue];
        }
        
        return [NSString stringWithFormat:@"Total cost: $%.2f", total];
    }
    
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        YTProduct *product = nil;
        
        if (indexPath.section == 0) {
            product = [self.products objectAtIndex:indexPath.row];
        } else {
            product = [self.purchasedProducts objectAtIndex:indexPath.row];
        }
        
        [[YTDBManager Manager].managedObjectContext deleteObject:product];
        [[YTDBManager Manager] saveContext];
        
        [self refreshTable];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YTProduct *product = nil;
    
    if (indexPath.section == 0) {
        product = [self.products objectAtIndex:indexPath.row];
    } else {
        product = [self.purchasedProducts objectAtIndex:indexPath.row];
    }
    
    if ([product.isPurchased boolValue]) {
        product.isPurchased = [NSNumber numberWithBool:NO];
    } else {
        product.isPurchased = [NSNumber numberWithBool:YES];
    }
    
    NSManagedObjectContext *context = [YTDBManager Manager].managedObjectContext;
    
    NSError *error = nil;
    if ([context save:&error] == YES) {
        
        [self refreshTable];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
        
    YTProduct *product = nil;
    
    if (indexPath.section == 0) {
        product = [self.products objectAtIndex:indexPath.row];
    } else {
        product = [self.purchasedProducts objectAtIndex:indexPath.row];
    }
    
    [self addProductWithProduct:product];
}

@end
