//
//  MonitorDriverProgressViewController.m
//  Reference App
//
//  Created by David Deller on 9/10/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "MonitorDriverProgressViewController.h"

@interface MonitorDriverProgressViewController ()

@property (nonatomic, strong, nullable) TGTurnByTurnViewController *turnByTurnViewController;

@end

@implementation MonitorDriverProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)go:(id)sender {
    [self startTurnByTurn];
}

- (void)startTurnByTurn {
    TGDrivingSimulator.sharedDrivingSimulator.startingCoordinate = CLLocationCoordinate2DMake(34.101558, -118.340944); // Grauman's Chinese Theatre
    TGDrivingSimulator.sharedDrivingSimulator.enabled = YES;
    
    // Increase the simulated driving speed above realistic levels so that we can see the console messages more quickly
    TGDrivingSimulator.sharedDrivingSimulator.citySpeed = 200; // meters per second
    TGDrivingSimulator.sharedDrivingSimulator.highwaySpeed = 200; // meters per second
    
    // Get these coordinates from your app, these are just a sample
    NSArray<TGWaypoint *> *waypoints = @[
        [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.101558, -118.340944) address:nil description:@"Grauman's Chinese Theatre"],
        [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.07902875, -118.379441) address:nil description:@"Quarter point"],
        [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.0564995, -118.417938) address:nil description:@"Midpoint"],
        [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.03397025, -118.456435) address:nil description:@"Three-quarters point"],
        [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.011441, -118.494932) address:nil description:@"Santa Monica Pier"],
    ];
    
    // Configure turn-by-turn navigation
    TGTurnByTurnConfiguration *config = [TGTurnByTurnConfiguration new];
    config.showsOriginIcon = NO;
    config.commencementSpeech = @"Let's go!";
    config.proceedToRouteSpeech = @"Please proceed to the route.";
    config.arrivalSpeech = @"You have arrived.";
    
    config.routeRequest = [TGRouteRequest.alloc initWithWaypoints:waypoints];
    
    // If you’d rather skip the preview and jump straight into directions, you can do that:
    TGTurnByTurnViewController *viewController = [TGTurnByTurnViewController createWithConfiguration:config];
    [self presentViewController:viewController animated:YES completion:nil];
    
    self.turnByTurnViewController = viewController;
    [self setupMonitoring];
}

- (void)setupMonitoring {
    [NSNotificationCenter.defaultCenter addObserverForName:TGTelemetryInitializedNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        TGRoute *route = notification.userInfo[TGTelemetryUserInfoRoute];
        TGRouteSegment *routeSegment = notification.userInfo[TGTelemetryUserInfoRouteSegment];
        if (route == nil || routeSegment == nil) {
            return;
        }
        
        NSLog(@"Turn-by-turn navigation status: initialized for route: %@ starting at: %@", route, routeSegment.originWaypoint.addressDescription);
    }];
    
    [NSNotificationCenter.defaultCenter addObserverForName:TGTelemetryOnRouteNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        NSLog(@"Turn-by-turn navigation status: on route");
    }];
    
    [NSNotificationCenter.defaultCenter addObserverForName:TGTelemetryProceedingToRouteNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        NSLog(@"Turn-by-turn navigation status: driver is proceeding to route");
    }];
    
    [NSNotificationCenter.defaultCenter addObserverForName:TGTelemetryCurrentPointChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        TGPoint *fromPoint = notification.userInfo[TGTelemetryUserInfoFromPoint];
        TGPoint *toPoint = notification.userInfo[TGTelemetryUserInfoToPoint];
        NSDate *ETA = notification.userInfo[TGTelemetryUserInfoETA];
        if (fromPoint == nil || toPoint == nil || ETA == nil) {
            return;
        }
        
        NSLog(@"Turn-by-turn navigation status: driver has moved from point %f,%f to point %f,%f with ETA: %@", fromPoint.coordinate.latitude, fromPoint.coordinate.longitude, toPoint.coordinate.latitude, toPoint.coordinate.longitude, ETA);
    }];
    
    [NSNotificationCenter.defaultCenter addObserverForName:TGTelemetryNextTurnChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        TGPoint *turnPoint = notification.userInfo[TGTelemetryUserInfoTurnPoint];
        TGTurn *turn = turnPoint.turn;
        
        NSLog(@"Turn-by-turn navigation status: currently displayed upcoming turn: %@ on to %@", turn.direction, turn.street.name);
    }];
    
    [NSNotificationCenter.defaultCenter addObserverForName:TGTelemetryOffRouteNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        NSLog(@"Turn-by-turn navigation status: driver is off-route");
    }];
    
    [NSNotificationCenter.defaultCenter addObserverForName:TGTelemetryReroutingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        NSLog(@"Turn-by-turn navigation status: driver is rerouting");
    }];
    
    [NSNotificationCenter.defaultCenter addObserverForName:TGTelemetryReroutedNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        NSLog(@"Turn-by-turn navigation status: driver has rerouted");
    }];
    
    [NSNotificationCenter.defaultCenter addObserverForName:TGTelemetryCancelledNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        NSLog(@"Turn-by-turn navigation status: driver cancelled navigation");
    }];
    
    [NSNotificationCenter.defaultCenter addObserverForName:TGTelemetrySegmentConcludedNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        TGRoute *route = notification.userInfo[TGTelemetryUserInfoRoute];
        TGRouteSegment *routeSegment = notification.userInfo[TGTelemetryUserInfoRouteSegment];
        if (route == nil || routeSegment == nil) {
            return;
        }
        
        NSLog(@"Turn-by-turn navigation status: driver has arrived at a destination: '%@' in route: %@", routeSegment.destinationWaypoint.addressDescription, route);
    }];
    
    [NSNotificationCenter.defaultCenter addObserverForName:TGTelemetrySegmentAdvancedNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        TGRoute *route = notification.userInfo[TGTelemetryUserInfoRoute];
        TGRouteSegment *routeSegment = notification.userInfo[TGTelemetryUserInfoRouteSegment];
        if (route == nil || routeSegment == nil) {
            return;
        }
        
        NSLog(@"Turn-by-turn navigation status: driver has advanced to the next segment: '%@' in route: %@", routeSegment.destinationWaypoint.addressDescription, route);
    }];
    
    [NSNotificationCenter.defaultCenter addObserverForName:TGTelemetryRouteConcludedNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        TGRoute *route = notification.userInfo[TGTelemetryUserInfoRoute];
        TGRouteSegment *routeSegment = notification.userInfo[TGTelemetryUserInfoRouteSegment];
        if (route == nil || routeSegment == nil) {
            return;
        }
        
        NSLog(@"Turn-by-turn navigation status: driver has arrived at final destination: '%@' in route: %@", routeSegment.destinationWaypoint.addressDescription, route);
    }];
}

@end
