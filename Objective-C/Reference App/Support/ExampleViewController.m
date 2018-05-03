//
//  ExampleViewController.m
//  Reference App
//
//  Created by David Deller on 5/3/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "ExampleViewController.h"

@interface ExampleViewController ()

@end

@implementation ExampleViewController

- (void)handleError:(NSError *)error {
    [self handleError:error viewController:nil];
}

- (void)handleError:(NSError *)error viewController:(UIViewController *)viewController {
    NSString *title = error.localizedDescription;
    NSString *message = @"This error alert is implemented by the Reference App, not the TallyGo SDK. The method is named -handleError:. You should provide your own error handling instead.";
    
    [self handleErrorWithTitle:title message:message viewController:viewController];
}

- (void)handleErrorWithTitle:(NSString *)title message:(NSString *)message viewController:(UIViewController *)viewController {
    if (viewController == nil) {
        viewController = self;
    }
    
    if (viewController.presentedViewController != nil) {
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    
    [viewController presentViewController:alert animated:YES completion:nil];
}

@end
