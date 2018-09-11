//
//  GetRouteViewController.m
//  Reference App
//
//  Created by David Deller on 5/3/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "GetRouteViewController.h"

@interface GetRouteViewController ()

@end

@implementation GetRouteViewController

- (IBAction)go:(id)sender {
    [self getRoute];
}

- (void)getRoute {
    // Get these coordinates from your app, these are just a sample
    TGWaypoint *origin = [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.101558, -118.340944)]; // Grauman's Chinese Theatre
    TGWaypoint *destination = [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.011441, -118.494932)]; // Santa Monica Pier
    
    TGRouteRequest *request = [TGRouteRequest.alloc initWithOriginWaypoint:origin destinationWaypoint:destination];
    
    [TGNavigationService routeForRequest:request completionHandler:^(TGRouteResponse * _Nonnull response) {
        if (response.error != nil) {
            // handle error
            
            [self handleError:response.error];
            
        } else {
            TGRoute *route = response.route;
            // do something with route
            
            [self handleOutput:route];
        }
    }];

}

@end
