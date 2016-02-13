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

@interface YTProductTableViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) NSMutableArray *purchasedProducts;
@property (strong, nonatomic) NSFetchedResultsController *frc;

@end

@implementation YTProductTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Products";
    self.purchasedProducts = [NSMutableArray array];
    
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addProductWithProduct:)];
    self.frc = nil;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.frc = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSFetchedResultsController *) frc {
    if (_frc) {
        return _frc;
    }
    
    NSManagedObjectContext *context = [YTDBManager Manager].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[[YTProduct class] description]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"basket = %@", self.basketId];
    [request setPredicate:predicate];
    NSSortDescriptor *sortByPurchased = [NSSortDescriptor sortDescriptorWithKey:@"isPurchased" ascending:NO];
    NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    [request setSortDescriptors:@[sortByTitle, sortByPurchased]];
    [request setFetchBatchSize:25];
    
    _frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:@"isPurchased" cacheName:nil];
    _frc.delegate = self;
    

    NSError *error = nil;
    
    if (![_frc performFetch:&error]) {
        NSLog(@"GetAll error: %@", [error localizedDescription]);
    }
    
    return _frc;
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

    return [self.frc.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    id<NSFetchedResultsSectionInfo> sectionInfo = self.frc.sections[section];
    
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YTProductCell *cell = [tableView dequeueReusableCellWithIdentifier:@"product_cell" forIndexPath:indexPath];
    YTProduct *product = [self.frc objectAtIndexPath:indexPath];
    
    cell.productTileLabel.text = product.title;
    cell.productDescriptionLabel.text = [NSString stringWithFormat:@"amount %i x price $%.2f = $%.2f", [product.amount intValue], [product.price floatValue], ([product.amount intValue] * [product.price floatValue])];
    if ([product.isPurchased boolValue]) {
        cell.productTileLabel.textColor = [UIColor greenColor];
    } else {
        cell.productTileLabel.textColor = [UIColor blackColor];
    }
    
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return [NSString stringWithFormat:@"Need buy this products"];
    }
    if (section == 1){
        
        return [NSString stringWithFormat:@"Purchased products"];
    }
    
    return nil;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    NSArray *products = [self.frc fetchedObjects];
    self.purchasedProducts = nil;
    self.purchasedProducts = [NSMutableArray array];
    
    for (YTProduct *product in products) {
        if ([product.isPurchased boolValue]) {
            [self.purchasedProducts addObject:product];
        }
    }
    
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
        
        YTProduct *product = [self.frc objectAtIndexPath:indexPath];
        
        [[YTDBManager Manager].managedObjectContext deleteObject:product];
        [[YTDBManager Manager] saveContext];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YTProduct *product = [self.frc objectAtIndexPath:indexPath];
    
    if ([product.isPurchased boolValue]) {
        product.isPurchased = [NSNumber numberWithBool:NO];
    } else {
        product.isPurchased = [NSNumber numberWithBool:YES];
    }
    
    [[YTDBManager Manager] saveContext];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
        
    YTProduct *product = [self.frc objectAtIndexPath:indexPath];
    
    [self addProductWithProduct:product];
}

#pragma mark - NSFetchedResultsControllerDelegate

-(void) controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

-(void) controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationLeft];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationRight];
            break;
        default:
            break;
    }
}

-(void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationLeft];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationRight];
            break;
            
        case NSFetchedResultsChangeUpdate:
            //            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
            //                             withRowAnimation:UITableViewRowAnimationFade];
            //            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            //            if (cell != nil) {
            //                [self configureCell:cell withObject:anObject];
            //            }
            
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

-(void) controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
