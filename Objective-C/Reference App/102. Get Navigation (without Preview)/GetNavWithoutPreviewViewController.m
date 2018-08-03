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
    CLLocationCoordinate2D origin = CLLocationCoordinate2DMake(34.101558, -118.340944); // Grauman's Chinese Theatre
    CLLocationCoordinate2D destination = CLLocationCoordinate2DMake(34.011441, -118.494932); // Santa Monica Pier
    
    // Configure turn-by-turn navigation
    TGTurnByTurnConfiguration *config = [TGTurnByTurnConfiguration new];
    config.showsOriginIcon = NO;
    config.origin = origin;
    config.destination = destination;
    config.commencementSpeech = @"Let's go!";
    config.proceedToRouteSpeech = @"Please proceed to the route.";
    config.arrivalSpeech = @"You have arrived.";
    
    // If you’d rather skip the preview and jump straight into directions, you can do that:
    TGTurnByTurnViewController *viewController = [TGTurnByTurnViewController createWithConfiguration:config];
    [self presentViewController:viewController animated:YES completion:nil];

}

@end
