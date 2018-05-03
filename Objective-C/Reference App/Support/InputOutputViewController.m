//
//  InputOutputViewController.m
//  Reference App
//
//  Created by David Deller on 5/3/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "InputOutputViewController.h"

@interface InputOutputViewController ()

@property (nonatomic, weak) IBOutlet UITextField *inputField;

@end

@implementation InputOutputViewController

- (IBAction)goSubmit:(id)sender {
    [self clearOutput];
    
    if (self.inputField.text != nil) {
        [self handleInput:self.inputField.text];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self clearOutput];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self clearOutput];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self goSubmit:textField];
    
    return NO;
}

#pragma mark -

- (void)handleInput:(NSString *)input {
    // Subclass should override
}

@end
