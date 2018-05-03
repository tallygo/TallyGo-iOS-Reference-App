//
//  InsertMapViewWithStoryboardViewController.m
//  Reference App
//
//  Created by David Deller on 5/3/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "InsertMapViewWithStoryboardViewController.h"

@interface InsertMapViewWithStoryboardViewController ()

@property (nonatomic, weak) IBOutlet TGMapView *mapView;

@end

@implementation InsertMapViewWithStoryboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Part 2: Customize it to your liking
    self.mapView.tintColor = UIColor.greenColor;
    self.mapView.zoomLevel = 12;
    self.mapView.showsUserLocation = YES;
    [self.mapView setUserTrackingMode:MGLUserTrackingModeFollow animated:NO];
}

@end
