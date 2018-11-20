//
//  NavWithWaypointsViewController.m
//  Reference App
//
//  Created by David Deller on 8/3/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "NavWithWaypointsViewController.h"

@interface NavWithWaypointsViewController ()

@end

@implementation NavWithWaypointsViewController

- (IBAction)go:(id)sender {
    TGDrivingSimulator.sharedDrivingSimulator.startingCoordinate = CLLocationCoordinate2DMake(34.101558, -118.340944); // Grauman's Chinese Theatre
    TGDrivingSimulator.sharedDrivingSimulator.enabled = YES;
    
    // Get these coordinates from your app, these are just a sample
    NSArray<TGWaypoint *> *waypoints = @[
        [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.101558, -118.340944) address:nil description:@"Grauman's Chinese Theatre"],
        [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.07902875, -118.379441) address:nil description:@"Quarter point"],
        [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.0564995, -118.417938) address:nil description:@"Midpoint"],
        [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.03397025, -118.456435) address:nil description:@"Three-quarters point"],
        [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.011441, -118.494932) address:nil description:@"Santa Monica Pier"],
    ];
    
    // Configure turn-by-turn navigation
    TGTurnByTurnConfiguration *config = [TGTurnByTurnConfiguration new];
    config.showsOriginIcon = NO;
    config.commencementSpeech = @"Let's go!";
    config.proceedToRouteSpeech = @"Please proceed to the route.";
    config.arrivalSpeech = @"You have arrived.";
    
    config.routeRequest = [TGRouteRequest.alloc initWithWaypoints:waypoints];
    
    // Display it
    UINavigationController *viewController = [[TGPreviewViewController createWithConfiguration:config] embedInNavigationController];
    [self presentViewController:viewController animated:YES completion:nil];
}

@end
