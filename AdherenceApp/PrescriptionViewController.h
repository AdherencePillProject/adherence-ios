//
//  PrescriptionViewController.h
//  AdherenceApp
//
//  Created by Shana Azria Dev on 3/4/16.
//  Copyright © 2016 Shana Azria Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrescriptionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSString* bottleName;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
