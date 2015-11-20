//
//  NavViewController.h
//  AdherenceApp
//
//  Created by Shana Azria Dev on 11/19/15.
//  Copyright © 2015 Shana Azria Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FCVerticalMenu/FCVerticalMenu.h>

@interface NavViewController : UINavigationController <FCVerticalMenuDelegate>

@property (strong, readonly, nonatomic) FCVerticalMenu *verticalMenu;

-(IBAction)openVerticalMenu:(id)sender;

@end
