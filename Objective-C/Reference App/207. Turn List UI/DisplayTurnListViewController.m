//
//  DisplayTurnListViewController.m
//  Reference App
//
//  Created by David Deller on 5/3/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "DisplayTurnListViewController.h"

@interface DisplayTurnListViewController ()

@end

@implementation DisplayTurnListViewController

- (IBAction)go:(id)sender {
    [self getRoute];
}

- (void)getRoute {
    // Get these coordinates from your app, these are just a sample
    CLLocationCoordinate2D origin = CLLocationCoordinate2DMake(34.101558, -118.340944); // Grauman's Chinese Theatre
    CLLocationCoordinate2D destination = CLLocationCoordinate2DMake(34.011441, -118.494932); // Santa Monica Pier
    
    TGRouteRequest *request = [TGRouteRequest.alloc initWithOrigin:origin destination:destination];
    
    [TGNavigationService routeForRequest:request completionHandler:^(TGRouteResponse * _Nonnull response) {
        if (response.error != nil) {
            // handle error
            
            [self handleError:response.error];
            
        } else {
            TGRoute *route = response.route;
            // do something with route
            
            [self showTurnList:route];
        }
    }];
    
}

- (void)showTurnList:(TGRoute *)route {
    TGTurnListViewController *viewController = [TGTurnListViewController create];
    viewController.segment = route.segments.firstObject;
    
    if (self.navigationController != nil) {
        self.navigationController.navigationBar.hidden = NO;
        [self.navigationController pushViewController:viewController animated:YES];
        
    } else {
        viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pressDoneButton:)];
        [self presentViewController:[viewController embedInNavigationController] animated:YES completion:nil];
    }
}

// This method isn't necessary if you're pushing it onto a UINavigationController
- (void)pressDoneButton:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
