//
//  AddWaypointDuringNavViewController.m
//  Reference App
//
//  Created by David Deller on 8/3/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "AddWaypointDuringNavViewController.h"

@interface AddWaypointDuringNavViewController ()

@property (nonatomic, nullable) NSTimer *timer;

@end

@implementation AddWaypointDuringNavViewController

- (IBAction)go:(id)sender {
    TallyGo.simulatedCoordinate = CLLocationCoordinate2DMake(34.0555, -118.417938); // Midpoint
    
    // Get these coordinates from your app, these are just a sample
    NSArray<TGWaypoint *> *waypoints = @[
        [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.0555, -118.417938) address:nil description:@"Midpoint"],
        [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.011441, -118.494932) address:nil description:@"Santa Monica Pier"],
    ];
    
    // Configure turn-by-turn navigation
    TGTurnByTurnConfiguration *config = [TGTurnByTurnConfiguration new];
    config.showsOriginIcon = NO;
    config.commencementSpeech = @"Let's go!";
    config.proceedToRouteSpeech = @"Please proceed to the route.";
    config.arrivalSpeech = @"You have arrived.";
    
    config.routeRequest = [TGRouteRequest.alloc initWithWaypoints:waypoints];
    
    // Start navigtation
    TGTurnByTurnViewController *viewController = [TGTurnByTurnViewController createWithConfiguration:config];
    [self presentViewController:viewController animated:YES completion:nil];
    
    // Wait 30 seconds after starting navigation before adding a waypoint.
    // This simulates a server request that might automatically initiate this kind of action based on a realtime event.
    // Instead of a timer, you would use your own custom networking code to initiate this part.
    self.timer = [NSTimer scheduledTimerWithTimeInterval:30 repeats:NO block:^(NSTimer * _Nonnull timer) {
        TGWaypoint *waypointToAdd = [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.101558, -118.340944) address:nil description:@"Grauman's Chinese Theatre"];
        
        [viewController addWaypoint:waypointToAdd toEnd:NO completion:^(TGRoute * _Nullable newRoute, TGRouteSegment * _Nullable nextSegment, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Failed to add waypoint: %@", error.userInfo);
                return;
            }
            
            // Inform the driver what is happening. This plays an audio cue, but you might also want to include a non-blocking visual cue.
            NSString *destinationDescription = waypointToAdd.addressDescription;
            if (destinationDescription == nil) {
                destinationDescription = @"a new destination";
            }
            [TGVoiceSynthesis.sharedVoiceSynthesis say:[NSString stringWithFormat:@"A new delivery order has come in. You are being rerouted to %@", destinationDescription]];
        }];
    }];
}

@end
