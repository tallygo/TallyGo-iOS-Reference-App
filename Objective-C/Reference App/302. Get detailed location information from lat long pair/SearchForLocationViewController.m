//
//  SearchForLocationViewController.m
//  Reference App
//
//  Created by David Deller on 5/3/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "SearchForLocationViewController.h"

@interface SearchForLocationViewController ()

@end

@implementation SearchForLocationViewController

- (void)handleInput:(NSString *)input {
    [self searchUsingAddress:input];
}

- (void)searchUsingAddress:(nonnull NSString *)address {
    CLLocationCoordinate2D currentLocation = CLLocationCoordinate2DMake(34.101558, -118.340944); // Grauman's Chinese Theatre
    
    TGSearchRequest *request = [TGSearchRequest.alloc initWithSingleLine:address location:currentLocation searchExtent:nil suggestionKey:nil];
    
    [TGFindService searchWithRequest:request completionHandler:^(TGSearchResponse * _Nonnull response) {
        NSArray<TGSearchResult *> *results = response.results;
        // do something with results
        
        [self handleOutput:results];
    }];
}


@end
