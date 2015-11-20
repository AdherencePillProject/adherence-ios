//
//  ProgressViewController.m
//  AdherenceApp
//
//  Created by Shana Azria Dev on 11/19/15.
//  Copyright © 2015 Shana Azria Dev. All rights reserved.
//

#import "ProgressViewController.h"
#import "NavViewController.h"
#import "MBCircularProgressBarView.h"
#import "PillScheduleTableViewCell.h"

@interface ProgressViewController ()
@property (weak, nonatomic) IBOutlet MBCircularProgressBarView *progressBar;
@property(strong, nonatomic) NSMutableArray* times;

@end

@implementation ProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self.navigationController action:@selector(openVerticalMenu:)];
    self.times = [[NSMutableArray alloc] initWithObjects:@"08:30", @"09:15", @"12:15", @"13:10", @"13:11", @"17:50", @"18:30", @"19:00", @"23:11", @"23:55", nil];

    self.navigationItem.title = @"Today";
    [self.progressBar setValue:12.f animateWithDuration:3];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.times count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PillScheduleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"calCell"];
    cell.timeLabel.text = [self.times objectAtIndex:[indexPath row]];
    
    return cell;
}



@end
