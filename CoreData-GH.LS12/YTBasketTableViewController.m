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

@interface YTBasketTableViewController ()

@property(strong, nonatomic) NSMutableArray *baskets;
@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) id selectedBasketId;

@end

@implementation YTBasketTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [[YTDBManager Manager] removeAllBasckets];  //   !!!
    
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBascket)];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshTable {
    self.baskets = nil;
    self.baskets = [NSMutableArray arrayWithArray:[[YTDBManager Manager] getAllBaskets]];
    [self.table reloadData];
}

#pragma mark - Actions

-(void) addBascket {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    YTBasketViewController *basketController = [sb instantiateViewControllerWithIdentifier:@"bascketControllerIdentifier"];
  
    [self.navigationController pushViewController:basketController animated:YES];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YTBasket *basket = [self.baskets objectAtIndex:indexPath.row];
    self.selectedBasketId = basket.objectID;
    
    [self performSegueWithIdentifier:@"show_products" sender:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.baskets count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YTBascketCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basketCell" forIndexPath:indexPath];
    YTBasket *basket = [self.baskets objectAtIndex:indexPath.row];
    cell.title.text = [NSString stringWithFormat:@"%@", basket.title];
    cell.productCountLabel.text = [NSString stringWithFormat:@"%lu products", [basket.products count]];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd MMMM yyyy"];
    cell.createdAtDate.text = [NSString stringWithFormat:@"%@", [format stringFromDate:basket.createdAt]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        YTBasket *basket = [self.baskets objectAtIndex:indexPath.row];
        
        [[YTDBManager Manager].managedObjectContext deleteObject:basket];
        [[YTDBManager Manager] saveContext];
        
        [self refreshTable];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    YTProductTableViewController *vc = [segue destinationViewController];
    vc.basketId = self.selectedBasketId;
}

@end
