//
//  AllTableViewController.m
//  AdherenceApp
//
//  Created by Shana Azria Dev on 11/19/15.
//  Copyright © 2015 Shana Azria Dev. All rights reserved.
//

#import "AllTableViewController.h"
#import "NavViewController.h"
#import "AllTableViewCell.h"

@interface AllTableViewController ()
@property(strong, nonatomic) NSMutableArray* pillList;
@end

@implementation AllTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.pillList == nil) {
        self.pillList = [[NSMutableArray alloc] initWithObjects:@"Advil", @"Aderall", @"Xanax", @"Ponstyl", @"Benadryl", @"Vinamin C", nil];
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self.navigationController action:@selector(openVerticalMenu:)];
    
    self.navigationItem.title = @"All";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.pillList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AllTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"allCell"];
    cell.pillLabel.text = [self.pillList objectAtIndex:[indexPath row]];
    if ([indexPath row] == 1) {
        cell.timeLabel.text = @"IN 1 HOUR";
    } else if ([indexPath row] == 0) {
        cell.timeLabel.text = @"NOW";
    }else {
        cell.timeLabel.text = [NSString stringWithFormat:@"IN %ld HOURS", (long)[indexPath row]];
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
