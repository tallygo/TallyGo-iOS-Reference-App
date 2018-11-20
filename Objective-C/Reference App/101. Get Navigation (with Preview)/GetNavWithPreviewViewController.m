//
//  GetNavWithPreviewViewController.m
//  Reference App
//
//  Created by David Deller on 5/3/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "GetNavWithPreviewViewController.h"

@interface GetNavWithPreviewViewController ()

@end

@implementation GetNavWithPreviewViewController

- (IBAction)go:(id)sender {
    TGDrivingSimulator.sharedDrivingSimulator.startingCoordinate = CLLocationCoordinate2DMake(34.101558, -118.340944); // Grauman's Chinese Theatre
    TGDrivingSimulator.sharedDrivingSimulator.enabled = YES;
    
    // Get these coordinates from your app, these are just a sample
    TGWaypoint *origin = [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.101558, -118.340944)]; // Grauman's Chinese Theatre
    TGWaypoint *destination = [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.011441, -118.494932)]; // Santa Monica Pier
    
    // Configure turn-by-turn navigation
    TGTurnByTurnConfiguration *config = [TGTurnByTurnConfiguration new];
    config.showsOriginIcon = NO;
    config.originWaypoint = origin;
    config.destinationWaypoint = destination;
    config.commencementSpeech = @"Let's go!";
    config.proceedToRouteSpeech = @"Please proceed to the route.";
    config.arrivalSpeech = @"You have arrived.";
    
    // Display it
    UINavigationController *viewController = [[TGPreviewViewController createWithConfiguration:config] embedInNavigationController];
    [self presentViewController:viewController animated:YES completion:nil];
}

@end
