//
//  PrescriptionViewController.m
//  AdherenceApp
//
//  Created by Shana Azria Dev on 3/4/16.
//  Copyright © 2016 Shana Azria Dev. All rights reserved.
//

#import "PrescriptionViewController.h"
#import <Parse/Parse.h>
#import "BottlesTableViewCell.h"

@interface PrescriptionViewController ()

@end

@implementation PrescriptionViewController {
    NSMutableArray *prescriptions;
    PFObject *patient;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    prescriptions = [[NSMutableArray alloc] init];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"arrayFilled"
                                               object:nil];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Patient"];
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:@"gR7568OUYX"
                                 block:^(PFObject *userF, NSError *error) {
                                     // Now let's update it with some new data. In this case, only cheatMode and score
                                     // will get sent to the cloud. playerName hasn't changed.
                                     if (userF) {
                                         patient = userF;
                                         NSLog(@"found user %@", userF);
                                         NSArray *pArr = userF[@"prescriptions"];
                                         for (int i = 0; i < [pArr count]; i++) {
                                             if (i == [pArr count] - 1) {
                                                 [self getPrescription:[pArr objectAtIndex:i] isLast:YES];
                                             } else {
                                                 [self getPrescription:[pArr objectAtIndex:i] isLast:NO];
                                             }
                                             
                                         }
                                         
                                     }
                                     
                                 }];
    
    
    // Do any additional setup after loading the view.
}

- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"arrayFilled"]) {
        NSLog(@"notif!");
        [self.tableView reloadData];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getPrescription:(NSString *)objID isLast:(bool)isLAstOne{
    NSLog(@"prescription obj id %@", objID);
    PFQuery *query = [PFQuery queryWithClassName:@"Prescription"];
    [query getObjectInBackgroundWithId:objID
                                 block:^(PFObject *p, NSError *error) {
                                     // Now let's update it with some new data. In this case, only cheatMode and score
                                     // will get sent to the cloud. playerName hasn't changed.
                                     if (p) {
                                         NSLog(@"found p %@", p);
                                         if (!p[@"bottle"]) {
                                             [prescriptions addObject:p];
                                             if (isLAstOne){
                                                 NSLog(@"prescription arr %@", prescriptions);
                                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                     [[NSNotificationCenter defaultCenter] postNotificationName: @"arrayFilled" object:nil];
                                                 });
                                                 
                                             }
                                         }
                                         
                                         
                                     }
                                     
                                 }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [prescriptions count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BottlesTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];
    cell.bottleLabel.text = [prescriptions objectAtIndex:indexPath.row][@"pillName"];
    
    return cell;
}

- (void) updatePrescription:(PFObject *)bottle withObjId:(NSString *)objID {
    PFQuery *query = [PFQuery queryWithClassName:@"Prescription"];
    [query getObjectInBackgroundWithId:objID
                                 block:^(PFObject *p, NSError *error) {
                                     p[@"bottle"] = bottle;
                                     [p saveInBackground];
                                 }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BottlesTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];
    NSLog(@"cell text %@", [prescriptions objectAtIndex:indexPath.row][@"pillName"]);
    PFObject *bottle = [PFObject objectWithClassName:@"Bottle"];
    bottle[@"UUID"] = [prescriptions objectAtIndex:indexPath.row][@"pillName"];
    bottle[@"owner"] = patient;
    [bottle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The object has been saved.
            PFObject *p = [prescriptions objectAtIndex:indexPath.row];
            [self updatePrescription:bottle withObjId:p.objectId];
        } else {
            // There was a problem, check error.description
        }
    }];
    
    UIAlertView *messageAlert = [[UIAlertView alloc]
                                 initWithTitle:@"Success" message:@"You just paired your bottle" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    // Display Alert Message
    [messageAlert show];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
