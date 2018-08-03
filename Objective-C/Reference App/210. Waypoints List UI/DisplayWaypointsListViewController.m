//
//  DisplayWaypointsListViewController.m
//  Reference App
//
//  Created by David Deller on 8/3/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "DisplayWaypointsListViewController.h"

@interface DisplayWaypointsListViewController ()

@end

@implementation DisplayWaypointsListViewController

- (IBAction)go:(id)sender {
    [self getRoute];
}

- (void)getRoute {
    // Get these coordinates from your app, these are just a sample
    NSArray<TGWaypoint *> *waypoints = @[
        [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.101558, -118.340944) address:nil description:@"Grauman's Chinese Theatre"],
        [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.07902875, -118.379441) address:nil description:@"Quarter point"],
        [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.0564995, -118.417938) address:nil description:@"Midpoint"],
        [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.03397025, -118.456435) address:nil description:@"Three-quarters point"],
        [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.011441, -118.494932) address:nil description:@"Santa Monica Pier"],
    ];
    
    TGRouteRequest *request = [TGRouteRequest.alloc initWithWaypoints:waypoints];
    
    [TGNavigationService routeForRequest:request completionHandler:^(TGRouteResponse * _Nonnull response) {
        if (response.error != nil) {
            // handle error
            
            [self handleError:response.error];
            
        } else {
            TGRoute *route = response.route;
            // do something with route
            
            [self showWaypointsList:route];
        }
    }];
    
}

- (void)showWaypointsList:(TGRoute *)route {
    TGWaypointsListViewController *viewController = [TGWaypointsListViewController create];
    viewController.route = route;
    
    viewController.nextWaypoint = route.segments.firstObject.destinationWaypoint;
    viewController.getCurrentLocationWaypoint = ^TGWaypoint * _Nonnull{
        return route.segments.firstObject.originWaypoint;
    };
    
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
