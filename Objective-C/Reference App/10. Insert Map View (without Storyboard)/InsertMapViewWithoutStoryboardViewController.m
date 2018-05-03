//
//  InsertMapViewWithoutStoryboardViewController.m
//  Reference App
//
//  Created by David Deller on 5/3/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "InsertMapViewWithoutStoryboardViewController.h"

@interface InsertMapViewWithoutStoryboardViewController ()

@end

@implementation InsertMapViewWithoutStoryboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Part 1: Initialize the view
    TGMapView *mapView = [TGMapView.alloc initWithFrame:self.view.bounds];
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    mapView.translatesAutoresizingMaskIntoConstraints = YES;
    
    // Part 2: Customize it to your liking
    mapView.tintColor = UIColor.greenColor;
    mapView.zoomLevel = 12;
    mapView.showsUserLocation = YES;
    [mapView setUserTrackingMode:MGLUserTrackingModeFollow animated:NO];
    
    // Part 3: Add it to your existing view
    [self.view addSubview:mapView];
}

@end
