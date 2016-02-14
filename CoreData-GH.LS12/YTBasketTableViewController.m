//
//  YTBasketTableViewController.m
//  CoreData-GH.LS12
//
//  Created by Yuriy T on 06.02.16.
//  Copyright © 2016 Yuriy T. All rights reserved.
//

#import "YTBasketTableViewController.h"
#import "YTDBManager.h"
#import "YTBascketCell.h"
#import "YTBasketViewController.h"
#import "YTProductTableViewController.h"
#import "YTBasket.h"

@interface YTBasketTableViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) NSFetchedResultsController *frc;
@property (strong, nonatomic) id selectedBasketId;

@end

@implementation YTBasketTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [[YTDBManager Manager] removeAllBasckets];  //   !!!
    
     self.clearsSelectionOnViewWillAppear = NO;
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBascket)];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[[YTBasket class] description]];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"basket = %@", self.basketId];
//    [request setPredicate:predicate];
    NSSortDescriptor *sortByCreated = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
    NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    [request setSortDescriptors:@[sortByTitle, sortByCreated]];
    [request setFetchBatchSize:25];
    
    _frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:@"createdAt" cacheName:nil];
    _frc.delegate = self;
    
    NSError *error = nil;
    
    if (![_frc performFetch:&error]) {
        NSLog(@"GetAll error: %@", [error localizedDescription]);
    }
    
    return _frc;
}

#pragma mark - Actions

-(void) addBascket {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    YTBasketViewController *basketController = [sb instantiateViewControllerWithIdentifier:@"bascketControllerIdentifier"];
  
    [self.navigationController pushViewController:basketController animated:YES];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YTBasket *basket = [self.frc objectAtIndexPath:indexPath];
    self.selectedBasketId = basket.objectID;
    
    [self performSegueWithIdentifier:@"show_products" sender:nil];
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
    YTBascketCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basketCell" forIndexPath:indexPath];
    YTBasket *basket = [self.frc objectAtIndexPath:indexPath];
    cell.title.text = [NSString stringWithFormat:@"%@", basket.title];
    cell.productCountLabel.text = [NSString stringWithFormat:@"%lu products", [basket.products count]];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd MMMM yyyy"];
    cell.createdAtDate.text = [NSString stringWithFormat:@"%@", [format stringFromDate:basket.createdAt]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        YTBasket *basket = [self.frc objectAtIndexPath:indexPath];
        
        [[YTDBManager Manager].managedObjectContext deleteObject:basket];
        [[YTDBManager Manager] saveContext];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

-(nullable NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = self.frc.sections[section];
    
    YTBasket *basket = [sectionInfo.objects firstObject];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd MMMM yyyy"];
    
    return [NSString stringWithFormat:@"%@", [format stringFromDate:basket.createdAt]];
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    YTProductTableViewController *vc = [segue destinationViewController];
    vc.basketId = self.selectedBasketId;
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
        case NSFetchedResultsChangeUpdate:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
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
