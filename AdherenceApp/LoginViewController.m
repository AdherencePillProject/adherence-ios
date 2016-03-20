//
//  LoginViewController.m
//  AdherenceApp
//
//  Created by Shana Azria Dev on 3/4/16.
//  Copyright © 2016 Shana Azria Dev. All rights reserved.
//

#import "LoginViewController.h"
#import "NavViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController () <UITextFieldDelegate>

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    self.passwordField.secureTextEntry = YES;
    self.navigationController.navigationBarHidden = YES;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self.navigationController action:@selector(openVerticalMenu:)];
    
    self.navigationItem.title = @"Pairings";
    // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)navigateToMainVC {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    UIViewController* controller = [mainStoryboard instantiateViewControllerWithIdentifier:@"middle"];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void) clearTextFields {
    self.usernameField.text = @"";
    self.passwordField.text = @"";
}

-(void)resignKeyboards {
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self resignKeyboards];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if ([textField isEqual:self.usernameField]) {
        [self.passwordField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return NO;
}

-(void) fadeErrorMessage {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.4
                              delay:0.2
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.errorLabel.alpha = 0;
                             
                         }
                         completion:^(BOOL finished) {
                             self.errorLabel.text = @"";
                             self.errorLabel.alpha = 1;
                         }];
        
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loginPressed:(id)sender {
    if ([self.usernameField.text isEqualToString:@""] || [self.passwordField.text isEqualToString:@""]) {
        self.errorLabel.text = @"Cannot have blank fields";
        [self fadeErrorMessage];
    } else {
        [PFUser logInWithUsernameInBackground:self.usernameField.text password:self.passwordField.text
                                        block:^(PFUser *user, NSError *error) {
                                            if (user) {
                                                self.errorLabel.text = @"Login Successful";
                                                [self navigateToMainVC];
                                                // Do stuff after successful login.
                                            } else {
                                                NSLog(@"Error - %@", error);
                                                self.errorLabel.text = @"Error siging up in.";
                                                // The login failed. Check error to see why.
                                            }
                                            [self clearTextFields];
                                            [self fadeErrorMessage];
                                        }];
        
    }

}
@end
