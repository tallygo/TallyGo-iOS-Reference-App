//
//  StartNewRouteUponArrivalViewController.m
//  Reference App
//
//  Created by David Deller on 9/11/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "StartNewRouteUponArrivalViewController.h"

@interface StartNewRouteUponArrivalViewController ()

@end

@implementation StartNewRouteUponArrivalViewController

- (IBAction)go:(id)sender {
    TallyGo.simulatedCoordinate = CLLocationCoordinate2DMake(34.101558, -118.340944); // Grauman's Chinese Theatre
    
    // Get these coordinates from your app, these are just a sample
    TGWaypoint *firstWaypoint = [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.101558, -118.340944)]; // Grauman's Chinese Theatre
    TGWaypoint *secondWaypoint = [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.108558, -118.336143)]; // Hollywood Heritage Museum
    
    // Configure turn-by-turn navigation
    TGTurnByTurnConfiguration *config = [TGTurnByTurnConfiguration new];
    config.originWaypoint = firstWaypoint;
    config.destinationWaypoint = secondWaypoint;
    
    // Start navigation
    TGTurnByTurnViewController *viewController = [TGTurnByTurnViewController createWithConfiguration:config];
    [self presentViewController:viewController animated:YES completion:nil];
    
    id observer = nil;
    observer = [NSNotificationCenter.defaultCenter addObserverForName:TGTelemetryRouteConcludedNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        TGRouteSegment *routeSegment = notification.userInfo[TGTelemetryUserInfoRouteSegment];
        if (routeSegment == nil) {
            return;
        }
        
        // Check to make sure the driver arrived at the place we expected
        if (routeSegment.destinationWaypoint != secondWaypoint) {
            // If not, you probably want to handle this situation appropriately.
            // For this example, we'll log a message and return.
            NSLog(@"The driver isn't where we expected...");
            return;
        }
        
        // Dismiss the existing turn-by-turn view controller
        [self dismissViewControllerAnimated:YES completion:nil];
        
        // Configure a new turn-by-turn navigation session. This time, we are going the opposite direction.
        TGTurnByTurnConfiguration *config = [TGTurnByTurnConfiguration new];
        config.originWaypoint = secondWaypoint;
        config.destinationWaypoint = firstWaypoint;
        
        TGTurnByTurnViewController *viewController = [TGTurnByTurnViewController createWithConfiguration:config];
        
        // Confirm with the driver that it's OK to proceed
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Proceeding to next destination" message:config.destinationWaypoint.addressDescription preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // Driver accepted, start the next session
            [self presentViewController:viewController animated:YES completion:nil];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Stop Navigation" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        
        // Prevent this observer from executing again the next time the driver arrives
        [NSNotificationCenter.defaultCenter removeObserver:observer];
    }];
}

@end
