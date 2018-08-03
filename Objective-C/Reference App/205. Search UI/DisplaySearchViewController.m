//
//  DisplaySearchViewController.m
//  Reference App
//
//  Created by David Deller on 5/3/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "DisplaySearchViewController.h"

@interface DisplaySearchViewController ()

// Put this inside your @interface
@property (nonatomic, nullable) UINavigationController *searchNavController;

@end

@implementation DisplaySearchViewController

- (IBAction)go:(id)sender {
    [self showSearch];
}

// Put this inside your @implementation
- (void)showSearch {
    TGSearchViewController *searchVC = [TGSearchViewController create];
    searchVC.delegate = self;
    
    UINavigationController *navController = [searchVC embedInNavigationController];
    [self presentViewController:navController animated:YES completion:nil];
    
    self.searchNavController = navController;
}

#pragma mark - TGSearchViewControllerDelegate

- (CLLocationCoordinate2D)exampleCoordinate {
    return CLLocationCoordinate2DMake(34.101558, -118.340944); // Grauman's Chinese Theatre
}

- (TGSearchExtent *)exampleSearchExtent {
    return [TGSearchExtent.alloc initWithSouthwestCoordinate:CLLocationCoordinate2DMake(34.055534, -118.37313)
                                         northeastCoordinate:CLLocationCoordinate2DMake(34.1504, -118.308757)];
}

- (CLLocationCoordinate2D)coordinateForRequestType:(TGSearchViewControllerRequestType)requestType {
    return self.exampleCoordinate;
    
    // Note: If you have a TGMapView or MGLMapView, you can get the current location like this:
    //return self.mapView.centerCoordinate;
}

- (TGSearchExtent *)searchExtentForRequestType:(TGSearchViewControllerRequestType)requestType {
    return self.exampleSearchExtent;
    
    // Note: If you have a TGMapView or MGLMapView, you can get the current bounds like this:
    //return [TGSearchExtent.alloc initWithCoordinateBounds:self.mapView.visibleCoordinateBounds];
}

- (void)didSelectSearchResult:(TGSearchResult *)searchResult {
    [self.searchNavController dismissViewControllerAnimated:YES completion:nil];
    
    // Do something with the selected search result
    
    [self handleOutput:searchResult];
}

@end
