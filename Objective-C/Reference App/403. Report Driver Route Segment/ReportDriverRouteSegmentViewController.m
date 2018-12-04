//
//  ReportDriverRouteSegmentViewController.m
//  Reference App
//
//  Created by David Deller on 5/3/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "ReportDriverRouteSegmentViewController.h"

@interface ReportDriverRouteSegmentViewController ()

@property (nonatomic, weak) IBOutlet UILabel *serverURLLabel;

@property (nonatomic, strong, nullable) TGTurnByTurnViewController *turnByTurnViewController;

// Put this inside your @interface
// Keep track of when and what we last reported.
@property (nonatomic, nullable) TGRouteSegment *lastReportedRouteSegment;

@property (nonatomic, nonnull) NSString *temporaryID;

@end

@implementation ReportDriverRouteSegmentViewController

// Put these inside your @implementation
// You can change these configuration values to suit your needs.
static NSString *const reportRouteSegmentURL = @"http://localhost:3200/drivers/route_segment";
static NSString *const reportRouteSegmentMethod = @"PUT";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *URL = [NSURL URLWithString:reportRouteSegmentURL];
    self.serverURLLabel.text = [NSString stringWithFormat:@"%@://%@:%@", URL.scheme, URL.host, URL.port];
    
    self.temporaryID = NSUUID.UUID.UUIDString;
}

- (IBAction)go:(id)sender {
    [self startTurnByTurn];
}

- (void)startTurnByTurn {
    TGDrivingSimulator.sharedDrivingSimulator.startingCoordinate = CLLocationCoordinate2DMake(34.101558, -118.340944); // Grauman's Chinese Theatre
    TGDrivingSimulator.sharedDrivingSimulator.enabled = YES;
    
    // Get these coordinates from your app, these are just a sample
    TGWaypoint *origin = [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.101558, -118.340944)]; // Grauman's Chinese Theatre
    TGWaypoint *destination = [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.011441, -118.494932)]; // Santa Monica Pier
    
    // Configure turn-by-turn navigation
    TGTurnByTurnConfiguration *config = [TGTurnByTurnConfiguration new];
    config.showsOriginIcon = NO;
    config.originWaypoint = origin;
    config.destinationWaypoint = destination;
    config.commencementSpeech = @"Let's go!";
    config.proceedToRouteSpeech = @"Please proceed to the route.";
    config.arrivalSpeech = @"You have arrived.";
    
    // If you’d rather skip the preview and jump straight into directions, you can do that:
    TGTurnByTurnViewController *viewController = [TGTurnByTurnViewController createWithConfiguration:config];
    [self presentViewController:viewController animated:YES completion:nil];
    
    self.turnByTurnViewController = viewController;
    [self setupReporting];
}

- (void)setupReporting {
    [NSNotificationCenter.defaultCenter addObserverForName:TGTelemetryInitializedNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        TGRouteSegment *newRouteSegment = notification.userInfo[TGTelemetryUserInfoRouteSegment];
        if (newRouteSegment == nil) {
            return;
        }
        
        [self reportRouteSegment:newRouteSegment];
    }];
}

- (void)reportRouteSegment:(nonnull TGRouteSegment *)routeSegment {
    // Only report when the route segment changes
    if (self.lastReportedRouteSegment == routeSegment) {
        return;
    }
    
    // Configure the request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:reportRouteSegmentURL]];
    request.HTTPMethod = reportRouteSegmentMethod;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:self.temporaryID forHTTPHeaderField:@"X-Temporary-ID"];
    
    NSError *error = nil;
    NSData *encodedData = [NSJSONSerialization dataWithJSONObject:routeSegment.dictionary options:0 error:&error];
    if (encodedData != nil) {
        request.HTTPBody = encodedData;
        
    } else {
        @throw error;
    }
    
    // Send the request
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            NSLog(@"Error reporting ETA: %@", error.userInfo);
            
        } else {
            // Optionally, you can do something with the successful response here.
        }
    }];
    [task resume];
    
    // Remember that we did this
    self.lastReportedRouteSegment = routeSegment;
}

@end
