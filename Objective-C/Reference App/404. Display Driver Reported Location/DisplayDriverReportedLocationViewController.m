//
//  DisplayDriverReportedLocationViewController.m
//  Reference App
//
//  Created by David Deller on 5/3/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "DisplayDriverReportedLocationViewController.h"

@interface DisplayDriverReportedLocationViewController ()

@property (weak, nonatomic) IBOutlet TGMapView *mapView;

@property (nonatomic, nullable) JFRWebSocket *socket;

@property (nonatomic, nonnull) MGLPointAnnotation *driverAnnotation;

@end

@implementation DisplayDriverReportedLocationViewController

typedef NSString *DriverEventType NS_TYPED_ENUM;

DriverEventType const DriverEventTypeCurrentLocation = @"current_location";
DriverEventType const DriverEventTypeETA = @"eta";

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
    if ([eventType isEqualToString:DriverEventTypeCurrentLocation]) {
        NSNumber *latitudeObj = payload[@"latitude"];
        NSNumber *longitudeObj = payload[@"longitude"];
        if (![latitudeObj isKindOfClass:NSNumber.class] || ![longitudeObj isKindOfClass:NSNumber.class]) {
            NSLog(@"Payload not in expected format: %@", payload);
            return;
        }
        
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latitudeObj.doubleValue, longitudeObj.doubleValue);
        [self handleLocationEvent:location];
        
    } else if ([eventType isEqualToString:DriverEventTypeETA]) {
        NSString *ETAString = payload[@"ETA"];
        if (![ETAString isKindOfClass:NSString.class]) {
            NSLog(@"Payload not in expected format: %@", payload);
            return;
        }
        
        NSISO8601DateFormatter *formatter = NSISO8601DateFormatter.new;
        NSDate *ETA = [formatter dateFromString:ETAString];
        if (![ETA isKindOfClass:NSDate.class]) {
            NSLog(@"Date not in expected format: %@", ETAString);
            return;
        }
        
        [self handleETAEvent:ETA];
        
    } else {
        NSLog(@"Unexpected event type: %@", eventType);
    }
}

- (void)handleLocationEvent:(CLLocationCoordinate2D)location {
    // Add the annotation to the map, if it hasn't been already
    if (self.mapView.annotations == nil || ![self.mapView.annotations containsObject:self.driverAnnotation]) {
        [self.mapView addAnnotation:self.driverAnnotation];
    }
    
    self.driverAnnotation.coordinate = location;
    
    [self.mapView setCenterCoordinate:location zoomLevel:15 animated:YES];
}

- (void)handleETAEvent:(NSDate *)ETA {
    NSDateFormatter *formatter = NSDateFormatter.new;
    formatter.dateStyle = NSDateFormatterNoStyle;
    formatter.timeStyle = NSDateFormatterLongStyle;
    
    NSString *ETAString = [formatter stringFromDate:ETA];
    self.navigationItem.title = [NSString stringWithFormat:@"ETA: %@", ETAString];
}

#pragma mark - MGLMapViewDelegate

- (MGLAnnotationImage *)mapView:(MGLMapView *)mapView imageForAnnotation:(id)annotation {
    static NSString *ID = @"driver annotation image";
    MGLAnnotationImage *annotationImage = [mapView dequeueReusableAnnotationImageWithIdentifier:ID];
    if (annotationImage != nil) {
        return annotationImage;
    } else {
        UIImage *image = TallyGoStyleKit.imageOfGenericPlaceIcon;
        
        return [MGLAnnotationImage annotationImageWithImage:image reuseIdentifier:ID];
    }
}

@end

