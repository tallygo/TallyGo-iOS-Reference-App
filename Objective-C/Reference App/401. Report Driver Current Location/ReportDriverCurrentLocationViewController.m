//
//  ReportDriverCurrentLocationViewController.m
//  Reference App
//
//  Created by David Deller on 5/3/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "ReportDriverCurrentLocationViewController.h"

@interface ReportDriverCurrentLocationViewController ()

@property (nonatomic, weak) IBOutlet UILabel *serverURLLabel;

@property (nonatomic, strong, nullable) TGTurnByTurnViewController *turnByTurnViewController;

// Put these inside your @interface
// Keep track of when and what we last reported.
@property (nonatomic, nullable) TGPoint *lastReportedLocationPoint;
@property (nonatomic, nullable) NSDate *lastReportedLocationTime;

@end

@implementation ReportDriverCurrentLocationViewController

// Put these inside your @implementation
// You can change these configuration values to suit your needs.
static CLLocationDistance const reportLocationPointTrigger = 100;
static NSTimeInterval const reportLocationTimeTrigger = 60;
static NSString *const reportLocationURL = @"http://localhost:3200/drivers/current_location";
static NSString *const reportLocationMethod = @"PUT";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *URL = [NSURL URLWithString:reportLocationURL];
    self.serverURLLabel.text = [NSString stringWithFormat:@"%@://%@:%@", URL.scheme, URL.host, URL.port];
}

- (IBAction)go:(id)sender {
    [self startTurnByTurn];
}

- (void)startTurnByTurn {
    TallyGo.simulatedCoordinate = CLLocationCoordinate2DMake(34.101558, -118.340944); // Grauman's Chinese Theatre
    
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
    [NSNotificationCenter.defaultCenter addObserverForName:TGTelemetryCurrentPointChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        TGPoint *newPoint = notification.userInfo[TGTelemetryUserInfoToPoint];
        if (newPoint == nil) {
            return;
        }
        
        [self reportLocation:newPoint];
    }];
}

- (void)reportLocation:(nonnull TGPoint *)point {
    // We should only continue if we haven't reported yet, or if one of our triggers has been satisfied.
    if (self.lastReportedLocationPoint != nil &&
        self.lastReportedLocationTime != nil &&
        TGLocationCoordinateDistanceFromCoordinate(self.lastReportedLocationPoint.coordinate, point.coordinate) <= reportLocationPointTrigger &&
        [NSDate.date timeIntervalSinceDate:self.lastReportedLocationTime] <= reportLocationTimeTrigger) {
        
        return;
    }
    
    // Collect the data we want to send
    NSDictionary *requestData = @{
        @"latitude": @(point.coordinate.latitude),
        @"longitude": @(point.coordinate.longitude),
    };
    
    // Configure the request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:reportLocationURL]];
    request.HTTPMethod = reportLocationMethod;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSError *error = nil;
    NSData *encodedData = [NSJSONSerialization dataWithJSONObject:requestData options:0 error:&error];
    if (encodedData != nil) {
        request.HTTPBody = encodedData;
        
    } else {
        @throw error;
    }
    
    // Send the request
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            NSLog(@"Error reporting current location: %@", error.userInfo);
            [self handleError:error viewController:self.turnByTurnViewController];
            
        } else {
            // Optionally, you can do something with the successful response here.
        }
    }];
    [task resume];
    
    // Remember that we did this
    self.lastReportedLocationPoint = point;
    self.lastReportedLocationTime = NSDate.date;
}

@end
