//
//  NavViewController.m
//  AdherenceApp
//
//  Created by Shana Azria Dev on 11/19/15.
//  Copyright © 2015 Shana Azria Dev. All rights reserved.
//

#import "NavViewController.h"
#import "AllTableViewController.h"
#import "ProgressViewController.h"
#import "CalendarViewController.h"

@interface NavViewController ()

@end

@implementation NavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configureVerticalMenu];
    self.verticalMenu.delegate = self;
    
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.verticalMenu.liveBlurBackgroundStyle = self.navigationBar.barStyle;
    self.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FCVerticalMenu Configuration
- (void)configureVerticalMenu
{
    FCVerticalMenuItem *item1 = [[FCVerticalMenuItem alloc] initWithTitle:@"All"
                                                             andIconImage:[UIImage imageNamed:@"settings-icon"]];
    
    FCVerticalMenuItem *item2 = [[FCVerticalMenuItem alloc] initWithTitle:@"Today"
                                                             andIconImage:nil];
    
    FCVerticalMenuItem *item3 = [[FCVerticalMenuItem alloc] initWithTitle:@"Calendar"
                                                             andIconImage:nil];
    
    FCVerticalMenuItem *item4 = [[FCVerticalMenuItem alloc] initWithTitle:@"Pairings"
                                                                                          andIconImage:nil];
    
    
    item1.actionBlock = ^{
        AllTableViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"left"];
        if ([self.viewControllers[0] isEqual:vc])
            return;
        
        [self setViewControllers:@[vc] animated:NO];
    };
    item2.actionBlock = ^{
        ProgressViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"middle"];
        
        if ([self.viewControllers[0] isEqual:vc])
            return;
        
        [self setViewControllers:@[vc] animated:NO];
        
    };
    item3.actionBlock = ^{
        
        CalendarViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"right"];
        
        if ([self.viewControllers[0] isEqual:vc])
            return;
        [self setViewControllers:@[vc] animated:NO];
        
    };
    item4.actionBlock = ^{
        
        CalendarViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"bottlesVC"];
        
        if ([self.viewControllers[0] isEqual:vc])
            return;
        [self setViewControllers:@[vc] animated:NO];
        
    };
    
    _verticalMenu = [[FCVerticalMenu alloc] initWithItems:@[item1, item2, item3, item4]];
    _verticalMenu.appearsBehindNavigationBar = YES;
    
}

-(IBAction)openVerticalMenu:(id)sender
{
    if (_verticalMenu.isOpen)
        return [_verticalMenu dismissWithCompletionBlock:nil];
    
    [_verticalMenu showFromNavigationBar:self.navigationBar inView:self.view];
}


#pragma mark - FCVerticalMenu Delegate Methods

/*-(void)menuWillOpen:(FCVerticalMenu *)menu
{
    NSLog(@"menuWillOpen hook");
}

-(void)menuDidOpen:(FCVerticalMenu *)menu
{
    NSLog(@"menuDidOpen hook");
}

-(void)menuWillClose:(FCVerticalMenu *)menu
{
    NSLog(@"menuWillClose hook");
}

-(void)menuDidClose:(FCVerticalMenu *)menu
{
    NSLog(@"menuDidClose hook");
}*/


@end
