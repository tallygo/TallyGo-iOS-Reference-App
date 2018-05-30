//
//  DisplayDriverMotionViewController.m
//  Reference App
//
//  Created by David Deller on 5/29/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "DisplayDriverMotionViewController.h"

@import MapKit;

@interface DisplayDriverMotionViewController ()

@property (weak, nonatomic) IBOutlet TGMapView *mapView;

@property (nonatomic, nullable) JFRWebSocket *socket;

// Put these in your @interface
@property (nonatomic, nonnull) MGLPointAnnotation *driverAnnotation;
@property (nonatomic, nullable) UIViewPropertyAnimator *animator;

@end

@implementation DisplayDriverMotionViewController

typedef NSString *DriverEventType NS_TYPED_ENUM;

DriverEventType const DriverEventTypeMotion = @"motion";

// Make sure to init the annotation when the view controller class loads
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.driverAnnotation = MGLPointAnnotation.new;
    self.mapView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupWebSocket];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self teardownWebSocket];
}

- (void)setupWebSocket {
    JFRWebSocket *socket = [JFRWebSocket.alloc initWithURL:[NSURL URLWithString:@"ws://localhost:3200/"] protocols:@[]];
    
    socket.onConnect = ^{
        NSLog(@"WebSocket is connected");
    };
    
    socket.onDisconnect = ^(NSError *error) {
        NSLog(@"WebSocket is disconnected: %@", error.userInfo);
    };
    
    socket.onText = ^(NSString *text) {
        NSError *error = nil;
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[text dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if (error != nil || ![data isKindOfClass:NSDictionary.class]) {
            NSLog(@"Error parsing JSON from WebSocket: %@, JSON: %@", error.userInfo, text);
            return;
        }
        
        DriverEventType eventType = data[@"event_type"];
        NSDictionary *payload = data[@"payload"];
        
        if (![eventType isKindOfClass:NSString.class] || ![payload isKindOfClass:NSDictionary.class]) {
            NSLog(@"JSON not in expected format: %@", text);
            return;
        }
        
        [self handleEvent:eventType payload:payload];
    };
    
    [socket connect];
    
    self.socket = socket;
}

- (void)teardownWebSocket {
    [self.socket disconnect];
}

- (void)handleEvent:(nonnull DriverEventType)eventType payload:(nonnull NSDictionary *)payload {
    if ([eventType isEqualToString:DriverEventTypeMotion]) {
        NSArray<NSArray<NSNumber *> *> *points = payload[@"points"];
        NSNumber *timeIntervalObj = payload[@"timeInterval"];
        if (![points isKindOfClass:NSArray.class] || ![points.firstObject isKindOfClass:NSArray.class] || ![timeIntervalObj isKindOfClass:NSNumber.class]) {
            NSLog(@"Payload not in expected format: %@", payload);
            return;
        }
        
        NSTimeInterval timeInterval = timeIntervalObj.doubleValue;
        
        NSMutableArray<NSValue *> *locations = [NSMutableArray arrayWithCapacity:points.count];
        for (NSArray<NSNumber *> *coordinateArray in points) {
            NSNumber *latitudeObj = coordinateArray[0];
            NSNumber *longitudeObj = coordinateArray[1];
            if (![latitudeObj isKindOfClass:NSNumber.class] || ![longitudeObj isKindOfClass:NSNumber.class]) {
                NSLog(@"Payload not in expected format: %@", payload);
                return;
            }
            
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitudeObj.doubleValue, longitudeObj.doubleValue);
            [locations addObject:[NSValue valueWithMKCoordinate:coordinate]];
        }
        
        [self handleMotionEventWithLocations:[NSArray arrayWithArray:locations] timeInterval:timeInterval];
        
    } else {
        NSLog(@"Unexpected event type: %@", eventType);
    }
}

- (void)handleMotionEventWithLocations:(NSArray<NSValue *> *)locations timeInterval:(NSTimeInterval)timeInterval {
    // We need at least one location
    if (locations.firstObject == nil) {
        return;
    }
    CLLocationCoordinate2D firstLocation = locations.firstObject.MKCoordinateValue;
    
    // Stop any previous animation that may still be running
    [self.animator stopAnimation:YES];
    self.animator = nil;
    
    // Add the annotation to the map, if it hasn't been already
    if (self.mapView.annotations == nil || ![self.mapView.annotations containsObject:self.driverAnnotation]) {
        [self.mapView addAnnotation:self.driverAnnotation];
    }
    
    // Zoom/pan the map to fit all of the coordinates, so the marker won't go off-screen
    NSInteger numCoordinates = locations.count;
    CLLocationCoordinate2D coordinatesCArray[numCoordinates];
    NSInteger index = 0;
    for (NSValue *locationValue in locations) {
        CLLocationCoordinate2D coordinate = locationValue.MKCoordinateValue;
        coordinatesCArray[index] = coordinate;
        index += 1;
    }
    [self.mapView setVisibleCoordinates:coordinatesCArray count:numCoordinates edgePadding:UIEdgeInsetsMake(30, 30, 30, 30) animated:NO];
    
    // Start out by jumping immediately to the first coordinate
    self.driverAnnotation.coordinate = firstLocation;
    
    NSArray<NSValue *> *locationsAfterFirst = [locations subarrayWithRange:NSMakeRange(1, (locations.count - 1))];
    
    // We need more coordinates if we're going to animate them
    if (locationsAfterFirst.count <= 0) {
        return;
    }
    
    UIViewPropertyAnimator *animator = [UIViewPropertyAnimator.alloc initWithDuration:timeInterval timingParameters:[UICubicTimingParameters.alloc initWithAnimationCurve:UIViewAnimationCurveLinear]];
    double eachKeyframePercent = (timeInterval / locationsAfterFirst.count);
    index = 0;
    
    // Loop through each of the coordinates (besides the first, which we already jumped to) and animate each of them in sequence
    for (NSValue *locationValue in locationsAfterFirst) {
        [animator addAnimations:^{
            self.driverAnnotation.coordinate = locationValue.MKCoordinateValue;
            
        } delayFactor:(index * eachKeyframePercent)];
        
        index += 1;
    }
    
    // Start the animation
    [animator startAnimation];
    
    // Save the animator for later, in case we need to interrupt it when a new one is ready
    self.animator = animator;
}

#pragma mark - MGLMapViewDelegate

- (MGLAnnotationView *)mapView:(MGLMapView *)mapView viewForAnnotation:(nonnull id<MGLAnnotation>)annotation {
    static NSString *ID = @"driver annotation view";
    MGLAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:ID];
    if (annotationView != nil) {
        return annotationView;
    } else {
        MGLAnnotationView *view = [MGLAnnotationView.alloc initWithAnnotation:annotation reuseIdentifier:ID];
        
        UIImageView *imageView = [UIImageView.alloc initWithImage:TallyGoStyleKit.imageOfGenericPlaceIcon];
        view.bounds = imageView.frame;
        [view addSubview:imageView];
        
        return view;
    }
}

@end
