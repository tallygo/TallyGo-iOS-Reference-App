//
//  AnnotateMapWithStaticPinsViewController.m
//  Reference App
//
//  Created by David Deller on 5/3/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "AnnotateMapWithStaticPinsViewController.h"

@interface AnnotateMapWithStaticPinsViewController ()

@property (nonatomic, weak) IBOutlet TGMapView *mapView;

@end

@implementation AnnotateMapWithStaticPinsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.zoomLevel = 12;
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake(34.101558, -118.340944); // Grauman's Chinese Theatre
    
    [self annotateMap];
}

- (void)annotateMap {
    // Declare the marker "pin" and set its coordinates, title, and subtitle
    MGLPointAnnotation *pin = MGLPointAnnotation.new;
    pin.coordinate = CLLocationCoordinate2DMake(34.101558, -118.340944);
    pin.title = @"Grauman's Chinese Theatre";
    pin.subtitle = @"6925 Hollywood Blvd, Hollywood, CA";
    
    // Add marker "pin" to the map
    [self.mapView addAnnotation:pin];
}

@end
