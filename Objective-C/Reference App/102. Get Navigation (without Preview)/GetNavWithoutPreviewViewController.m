//
//  GetNavWithoutPreviewViewController.m
//  Reference App
//
//  Created by David Deller on 5/3/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "GetNavWithoutPreviewViewController.h"

@interface GetNavWithoutPreviewViewController ()

@end

@implementation GetNavWithoutPreviewViewController

- (IBAction)go:(id)sender {
    TallyGo.simulatedCoordinate = CLLocationCoordinate2DMake(34.101558, -118.340944); // Grauman's Chinese Theatre
    
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
    
    // Start navigation
    TGTurnByTurnViewController *viewController = [TGTurnByTurnViewController createWithConfiguration:config];
    [self presentViewController:viewController animated:YES completion:nil];

}

@end
