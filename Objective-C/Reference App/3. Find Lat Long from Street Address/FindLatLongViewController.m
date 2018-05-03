//
//  FindLatLongViewController.m
//  Reference App
//
//  Created by David Deller on 5/3/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "FindLatLongViewController.h"

@interface FindLatLongViewController ()

@end

@implementation FindLatLongViewController

- (void)handleInput:(NSString *)input {
    [self findCoordinateFromAddress:input];
}

- (void)findCoordinateFromAddress:(nonnull NSString *)address {
    CLLocationCoordinate2D currentLocation = CLLocationCoordinate2DMake(34.101558, -118.340944); // Grauman's Chinese Theatre
    
    TGSearchRequest *request = [TGSearchRequest.alloc initWithSingleLine:address location:currentLocation searchExtent:nil suggestionKey:nil];
    
    [TGFindService searchWithRequest:request completionHandler:^(TGSearchResponse * _Nonnull response) {
        TGSearchResult *result = response.results.firstObject;
        if (result != nil) {
            CLLocationCoordinate2D coordinate = result.location;
            // Coordinate found!
            
            [self handleOutput:[NSValue valueWithMKCoordinate:coordinate]];
        }
    }];
}

@end
