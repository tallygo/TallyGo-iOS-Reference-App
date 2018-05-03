//
//  CreateMapVCViewController.m
//  Reference App
//
//  Created by David Deller on 5/3/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "CreateMapVCViewController.h"

@interface CreateMapVCViewController ()

@end

@implementation CreateMapVCViewController

- (IBAction)go:(id)sender {
    [self showMapVC];
}

- (UIViewController *)menuViewController {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"This is where your custom menu would go." message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Exit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    return alert;
}

- (void)showMapVC {
    TGMapViewController *mapViewController = [TGMapViewController create];
    __block TGMapViewController *blockVCRef = mapViewController;
    mapViewController.onSelectMenuButton = ^{
        [blockVCRef presentViewController:self.menuViewController animated:YES completion:nil];
    };
    
    [self presentViewController:mapViewController animated:YES completion:nil];
}

@end
